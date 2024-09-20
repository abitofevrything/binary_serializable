import 'package:binary_serializable/binary_serializable.dart';

abstract class MultiBinaryType<T, U> extends BinaryType<T> {
  final Map<U, BinaryType<T>> subtypes;

  const MultiBinaryType(this.subtypes);

  BinaryConversion<U> startPreludeConversion(void Function(U) onValue);
  U extractPrelude(T instance);

  @override
  Uint8List encode(input) {
    final prelude = extractPrelude(input);
    final subtype = subtypes[prelude];

    if (subtype == null) {
      throw 'no subtype matching $prelude found';
    }

    return subtype.encode(input);
  }

  @override
  BinaryConversion<T> startConversion(void Function(T p1) onValue) =>
      _MultiBinaryConversion(this, onValue);
}

class _MultiBinaryConversion<T, U> extends BinaryConversion<T> {
  MultiBinaryType<T, U> type;

  late final BinaryConversion<U> _preludeConversion =
      type.startPreludeConversion((prelude) {
    final subtype = type.subtypes[prelude];
    if (subtype == null) {
      throw 'no subtype matching $prelude found';
    }
    _currentConversion = subtype.startConversion(onValue);
  });

  late BinaryConversion _currentConversion = _preludeConversion;

  final BytesBuilder _preludeBytes = BytesBuilder(copy: false);

  _MultiBinaryConversion(this.type, super.onValue);

  @override
  void onValue(T value) {
    _currentConversion = _preludeConversion;
    super.onValue(value);
  }

  @override
  int add(Uint8List data) {
    var consumed = 0;

    if (identical(_currentConversion, _preludeConversion)) {
      consumed += _preludeConversion.add(data);
      _preludeBytes.add(Uint8List.sublistView(data, 0, consumed));

      if (identical(_currentConversion, _preludeConversion)) {
        if (consumed != data.length) {
          throw 'prelude conversion did not read entire input or emit a value';
        }
        return consumed;
      } else {
        data = Uint8List.sublistView(data, consumed);

        final expectedConsumption = _preludeBytes.length;
        final actualConsumption =
            _currentConversion.add(_preludeBytes.takeBytes());
        if (actualConsumption != expectedConsumption) {
          throw 'conversion did not read entire prelude';
        }
      }
    }

    consumed += _currentConversion.add(data);
    return consumed;
  }

  @override
  void flush() {
    _currentConversion.flush();
  }
}

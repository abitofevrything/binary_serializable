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
      MultiBinaryConversion(this, onValue);
}

class MultiBinaryConversion<T, U> extends BinaryConversion<T> {
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

  MultiBinaryConversion(this.type, super.onValue);

  @override
  void onValue(T value) {
    _currentConversion = _preludeConversion;
    super.onValue(value);
  }

  @override
  int add(Uint8List data) {
    if (identical(_currentConversion, _preludeConversion)) {
      final preludeConsumed = _preludeConversion.add(data);
      _preludeBytes.add(Uint8List.sublistView(data, 0, preludeConsumed));

      if (identical(_currentConversion, _preludeConversion)) {
        return preludeConsumed;
      } else {
        data = Uint8List.sublistView(data, preludeConsumed);

        final expectedConsumption = _preludeBytes.length;
        final consumed = _currentConversion.add(_preludeBytes.takeBytes());
        if (consumed != expectedConsumption) {
          throw 'conversion did not read entire prelude';
        }
      }
    }

    return _currentConversion.add(data);
  }

  @override
  void flush() {
    _currentConversion.flush();
  }
}

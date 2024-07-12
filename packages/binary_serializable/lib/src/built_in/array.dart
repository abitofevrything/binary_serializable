import 'dart:typed_data';

import 'package:binary_serializable/src/binary_conversion.dart';
import 'package:binary_serializable/src/binary_type.dart';

/// A [BinaryType] for lists containing a fixed number of elements.
class ArrayType<T> extends BinaryType<List<T>> {
  /// The length of the list to parse.
  final int length;

  /// The type used to parse the elements of the array.
  final BinaryType<T> type;

  const ArrayType(this.length, this.type) : assert(length > 0);

  @override
  Uint8List encode(List<T> input) {
    final builder = BytesBuilder(copy: false);
    for (final element in input) {
      builder.add(type.encode(element));
    }
    return builder.takeBytes();
  }

  @override
  BinaryConversion<List<T>> startConversion(
          void Function(List<T> p1) onValue) =>
      ArrayConversion(length, type, onValue);
}

class ArrayConversion<T> extends BinaryConversion<List<T>> {
  final int length;
  final BinaryType<T> type;

  late final BinaryConversion<T> _conversion = startConversion();

  late List<T> _current;
  int _index = 0;

  ArrayConversion(this.length, this.type, super.onValue) : assert(length > 0);

  @override
  int add(Uint8List data) {
    var offset = 0;
    do {
      offset += _conversion.add(Uint8List.sublistView(data, offset));
    } while (_index != 0 && offset < data.length);
    return offset;
  }

  BinaryConversion<T> startConversion() => type.startConversion((value) {
        if (_index == 0) {
          _current = List.filled(length, value);
        } else {
          _current[_index] = value;
        }

        _index++;

        if (_index == length) {
          onValue(_current);
          _index = 0;
        }
      });

  @override
  void flush() {
    _conversion.flush();
    if (_index != 0) throw 'pending array conversion';
  }
}

import 'dart:typed_data';

import 'package:binary_serializable/src/binary_conversion.dart';
import 'package:binary_serializable/src/binary_type.dart';

/// A [BinaryType] for lists containing a fixed number of elements.
class ArrayType<T> extends BinaryType<List<T>> {
  /// The length of the list to parse.
  final int length;

  /// The type used to parse the elements of the array.
  final BinaryType<T> type;

  const ArrayType(this.length, this.type) : assert(length != 0);

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
      _ArrayConversion(this, onValue);
}

class _ArrayConversion<T> extends BinaryConversion<List<T>> {
  final ArrayType<T> type;
  late final BinaryConversion<T> conversion = startConversion();

  late List<T> current;
  int index = 0;

  _ArrayConversion(this.type, super.onValue) {
    if (type.length == 0) onValue([]);
  }

  @override
  int add(Uint8List data) {
    var offset = 0;
    do {
      offset += conversion.add(Uint8List.sublistView(data, offset));
    } while (index != 0 && offset < data.length);
    return offset;
  }

  BinaryConversion<T> startConversion() => type.type.startConversion((value) {
        if (index == 0) {
          current = List.filled(type.length, value);
        } else {
          current[index] = value;
        }

        index++;

        if (index == type.length) {
          onValue(current);
          index = 0;
        }
      });

  @override
  void flush() {
    conversion.flush();
    if (index != 0) throw 'pending array conversion';
  }
}

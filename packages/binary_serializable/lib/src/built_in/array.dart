import 'dart:typed_data';

import 'package:binary_serializable/src/binary_conversion.dart';
import 'package:binary_serializable/src/binary_type.dart';

/// A [BinaryType] for lists containing a fixed number of elements.
class ArrayType<T> extends BinaryType<List<T>> {
  /// The number of elements in the lists to parse.
  final int length;

  /// The type used to read the elements of the list.
  final BinaryType<T> type;

  /// Create a new [ArrayType].
  const ArrayType(this.length, this.type);

  @override
  void encodeInto(List<T> input, BytesBuilder builder) {
    for (final element in input) {
      type.encodeInto(element, builder);
    }
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

  _ArrayConversion(this.type, super.onValue);

  @override
  int add(Uint8List data) {
    var offset = 0;
    do {
      offset +=
          conversion.add(data.buffer.asUint8List(data.offsetInBytes + offset));
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
    if (index != 0) throw StateError('Pending array conversion');
  }
}

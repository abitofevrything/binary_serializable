import 'dart:typed_data';

import 'package:binary_serializable/src/binary_conversion.dart';
import 'package:binary_serializable/src/binary_type.dart';

/// A [BinaryType] for variable length lists prefixed with an integer value
/// indicating their length.
class LengthPrefixedListType<T> extends BinaryType<List<T>> {
  /// The [BinaryType] used to read the length prefix.
  final BinaryType<int> lengthType;

  /// The [BinaryType] used to read the elements of the list.
  final BinaryType<T> type;

  /// Create a new [LengthPrefixedListType].
  const LengthPrefixedListType(this.lengthType, this.type);

  @override
  void encodeInto(List<T> input, BytesBuilder builder) {
    lengthType.encodeInto(input.length, builder);
    for (final element in input) {
      type.encodeInto(element, builder);
    }
  }

  @override
  BinaryConversion<List<T>> startConversion(
          void Function(List<T> p1) onValue) =>
      _ListConversion(this, onValue);
}

class _ListConversion<T> extends BinaryConversion<List<T>> {
  final LengthPrefixedListType<T> type;

  late final BinaryConversion<int> lengthConversion = startLengthConversion();
  late final BinaryConversion<T> conversion = startConversion();

  int? length;
  late List<T> current;
  int index = 0;

  _ListConversion(this.type, super.onValue);

  @override
  int add(Uint8List data) {
    var offset = 0;
    if (length == null) {
      offset += lengthConversion.add(data);
      if (length == null) return offset;
    }

    do {
      offset += conversion.add(Uint8List.sublistView(data, offset));
    } while (index != 0 && offset < data.length);

    return offset;
  }

  BinaryConversion<int> startLengthConversion() =>
      type.lengthType.startConversion((value) {
        if (value == 0) {
          onValue([]);
          return;
        }

        length = value;
      });

  BinaryConversion<T> startConversion() => type.type.startConversion((value) {
        if (index == 0) {
          current = List.filled(length!, value);
        } else {
          current[index] = value;
        }

        index++;

        if (index == length) {
          onValue(current);
          index = 0;
          length = null;
        }
      });

  @override
  void flush() {
    lengthConversion.flush();
    conversion.flush();
    if (length != null) throw StateError('Pending list conversion');
  }
}

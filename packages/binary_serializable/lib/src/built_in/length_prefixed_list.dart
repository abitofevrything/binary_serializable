import 'dart:typed_data';

import 'package:binary_serializable/src/binary_conversion.dart';
import 'package:binary_serializable/src/binary_type.dart';
import 'package:binary_serializable/src/built_in/array.dart';
import 'package:binary_serializable/src/composite_binary_conversion.dart';

class LengthPrefixedListType<T> extends BinaryType<List<T>> {
  final BinaryType<int> lengthType;
  final BinaryType<T> type;

  LengthPrefixedListType(this.lengthType, this.type);

  @override
  Uint8List encode(List<T> input) {
    final builder = BytesBuilder(copy: false);
    builder.add(lengthType.encode(input.length));
    for (final element in input) {
      builder.add(type.encode(element));
    }
    return builder.takeBytes();
  }

  @override
  BinaryConversion<List<T>> startConversion(
          void Function(List<T> p1) onValue) =>
      _ListConversion(this, onValue);
}

class _ListConversion<T> extends CompositeBinaryConversion<List<T>> {
  final LengthPrefixedListType<T> type;

  _ListConversion(this.type, super.onValue);

  @override
  BinaryConversion startConversion() =>
      type.lengthType.startConversion((length) {
        currentConversion = ArrayConversion(length, type.type, (result) {
          onValue(result);
          currentConversion = initialConversion;
        });
      });
}

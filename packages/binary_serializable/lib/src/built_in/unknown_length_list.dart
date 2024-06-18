import 'dart:typed_data';

import 'package:binary_serializable/src/binary_conversion.dart';
import 'package:binary_serializable/src/binary_type.dart';

class UnknownLengthListType<T> extends BinaryType<List<T>> {
  final BinaryType<T> type;

  const UnknownLengthListType(this.type);

  @override
  Uint8List encode(List<T> input) {
    final builder = BytesBuilder(copy: false);
    for (final element in input) {
      builder.add(type.encode(element));
    }
    return builder.takeBytes();
  }

  @override
  BinaryConversion<List<T>> startConversion(void Function(List<T>) onValue) =>
      _UnknownLengthListConversion(this, onValue);
}

class _UnknownLengthListConversion<T> extends BinaryConversion<List<T>> {
  final UnknownLengthListType<T> type;

  late final BinaryConversion<T> conversion = startConversion();

  List<T> current = [];

  _UnknownLengthListConversion(this.type, super.onValue);

  @override
  int add(Uint8List data) {
    conversion.addAll(data);
    return data.length;
  }

  BinaryConversion<T> startConversion() {
    return type.type.startConversion((value) {
      current.add(value);
    });
  }

  @override
  void flush() {
    conversion.flush();
    onValue(current);
    current = [];
  }
}

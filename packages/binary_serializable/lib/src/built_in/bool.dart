import 'dart:typed_data';

import 'package:binary_serializable/src/binary_conversion.dart';
import 'package:binary_serializable/src/binary_type.dart';

class BoolType extends BinaryType<bool> {
  const BoolType();

  @override
  Uint8List encode(bool input) {
    return Uint8List(1)..[0] = input ? 1 : 0;
  }

  @override
  BinaryConversion<bool> startConversion(void Function(bool) onValue) =>
      _BoolConversion(onValue);
}

class _BoolConversion extends BinaryConversion<bool> {
  _BoolConversion(super.onValue);

  @override
  int add(Uint8List data) {
    if (data.isEmpty) return 0;

    onValue(data[0] != 0);
    return 1;
  }

  @override
  void flush() {}
}

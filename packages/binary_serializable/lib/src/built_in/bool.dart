import 'dart:typed_data';

import 'package:binary_serializable/src/binary_conversion.dart';
import 'package:binary_serializable/src/binary_type.dart';

/// {@template bool_type}
/// A [BinaryType] for [bool]s.
///
/// `false` is encoded as a uint8 with a value of 0. `true` is encoded as any
/// other `uint8` value (though 1 is commonly used).
/// {@endtemplate}
class BoolType extends BinaryType<bool> {
  /// {@macro bool_type}
  const BoolType();

  @override
  void encodeInto(bool input, BytesBuilder builder) =>
      builder.addByte(input ? 1 : 0);

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
  void addAll(Uint8List data) {
    for (final value in data) {
      onValue(value != 0);
    }
  }

  @override
  void flush() {}
}

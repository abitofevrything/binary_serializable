import 'dart:typed_data';

import 'package:binary_serializable/src/binary_conversion.dart';
import 'package:binary_serializable/src/binary_type.dart';
import 'package:meta/meta_meta.dart';

@Target({TargetKind.classType, TargetKind.constructor})
class BinarySerializable {
  const BinarySerializable();
}

@Target({TargetKind.getter, TargetKind.field})
class Generic extends BinaryType<Never> {
  final String name;

  const Generic(this.name);

  @override
  Uint8List encode(input) => throw UnimplementedError(
      'Generic() types should be replaced by code generation');

  @override
  BinaryConversion<Never> startConversion(void Function(Never p1) onValue) =>
      throw UnimplementedError(
          'Generic() types should be replaced by code generation');
}

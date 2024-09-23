import 'dart:typed_data';

import 'package:binary_serializable/src/binary_conversion.dart';
import 'package:binary_serializable/src/binary_type.dart';
import 'package:meta/meta_meta.dart';

/// {@template binary_serializable}
/// An annotation to indicate `binary_serializable_generator` should generate a
/// [BinaryType] for a class.
///
/// When applied to a class, `binary_serializable_generator` generates a
/// [BinaryType] that calls the class's default (unnamed) constructor.
///
/// When applies to a constructor, `binary_serializable_generator` generates a
/// [BinaryType] for the constructor's enclosing class that calls the specified
/// constructor.
/// {@endtemplate}
@Target({TargetKind.classType, TargetKind.constructor})
class BinarySerializable {
  /// {@macro binary_serializable.}
  const BinarySerializable();
}

/// {@template generic}
/// A marker value to be used in place of a generic [BinaryType].
///
/// This class can be used in type annotations for
/// `binary_serializable_generator` in order to indicate the binary type depends
/// on a generic and should be a parameter to the generated [BinaryType].
///
/// The single parameter specifies which type parameter of the class to target.
///
/// This class must not be used at runtime.
/// {@endtemplate}
@Target({TargetKind.getter, TargetKind.field})
class Generic extends BinaryType<Never> {
  /// The name of the type parameter this generic will be substituted for.
  final String name;

  /// {@macro generic}
  const Generic(this.name);

  @override
  Uint8List encode(input) => throw UnimplementedError(
      'Generic() types should be replaced by code generation');

  @override
  BinaryConversion<Never> startConversion(void Function(Never p1) onValue) =>
      throw UnimplementedError(
          'Generic() types should be replaced by code generation');
}

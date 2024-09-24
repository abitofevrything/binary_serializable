import 'dart:typed_data';

import 'package:binary_serializable/src/binary_conversion.dart';
import 'package:binary_serializable/src/binary_type.dart';

/// A [BinaryType] for IEEE 754 single-precision binary floating-point numbers.
const float32 =
    FloatType(Float32List.bytesPerElement, _getFloat32, _setFloat32);

double _getFloat32(int offset, ByteData data, Endian endian) =>
    data.getFloat32(offset, endian);
void _setFloat32(double value, int offset, ByteData data, Endian endian) =>
    data.setFloat32(offset, value, endian);

/// A [BinaryType] for IEEE 754 double-precision binary floating-point numbers.
const float64 =
    FloatType(Float64List.bytesPerElement, _getFloat64, _setFloat64);

double _getFloat64(int offset, ByteData data, Endian endian) =>
    data.getFloat64(offset, endian);
void _setFloat64(double value, int offset, ByteData data, Endian endian) =>
    data.setFloat64(offset, value, endian);

/// A [BinaryType] for [double]s.
///
/// This [BinaryType] is a generic implementation for all double encodings. See
/// the constants declared in this library for instances of this type for
/// specific encodings.
class FloatType extends BinaryType<double> {
  /// The width of this type's encoding, in bytes.
  final int width;

  /// The endianness of this type's encoding.
  final Endian endian;

  final double Function(int offset, ByteData data, Endian endian) _getValue;
  final void Function(double value, int offset, ByteData data, Endian endian)
      _setValue;

  /// Create a new [FloatType].
  ///
  /// [_getValue] and [_setValue] are the functions used by this implementation
  /// to decode and encode integer values respectively by writing them into a
  /// [TypedData] buffer.
  ///
  /// [_setValue] is a function that takes an offset, a buffer and an endianness
  /// that returns the floating-point value in the buffer at the specified
  /// offset read with the given endianness.
  ///
  /// [_setValue] is a function that takes a value, an offset, a buffer and an
  /// endianness that sets the value in the buffer at the specified offset to
  /// the given value encoded with the given endianness.
  const FloatType(
    this.width,
    this._getValue,
    this._setValue, {
    this.endian = Endian.big,
  });

  @override
  Uint8List encode(double input) {
    final result = Uint8List(width);
    _setValue(input, 0, result.buffer.asByteData(), endian);
    return result;
  }

  @override
  void encodeInto(double input, BytesBuilder builder) =>
      builder.add(encode(input));

  @override
  BinaryConversion<double> startConversion(void Function(double) onValue) =>
      _FloatConversion(this, onValue);
}

class _FloatConversion extends BinaryConversion<double> {
  final FloatType type;
  final Uint8List buffer;
  var index = 0;

  _FloatConversion(this.type, super.onValue) : buffer = Uint8List(type.width);

  @override
  int add(Uint8List data) {
    if (index + data.length >= type.width) {
      buffer.setRange(index, buffer.length, data);
      onValue(type._getValue(0, buffer.buffer.asByteData(), type.endian));
      final consumed = buffer.length - index;
      index = 0;
      return consumed;
    } else {
      buffer.setAll(index, data);
      index += data.length;
      return data.length;
    }
  }

  @override
  void flush() {
    if (index != 0) throw StateError('Pending float conversion');
  }
}

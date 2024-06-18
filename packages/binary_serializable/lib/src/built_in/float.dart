import 'dart:typed_data';

import 'package:binary_serializable/src/binary_conversion.dart';
import 'package:binary_serializable/src/binary_type.dart';

const float32 =
    FloatType(Float32List.bytesPerElement, _getFloat32, _setFloat32);

double _getFloat32(int offset, ByteData data, Endian endian) =>
    data.getFloat32(offset, endian);
void _setFloat32(double value, int offset, ByteData data, Endian endian) =>
    data.setFloat32(offset, value, endian);

const float64 =
    FloatType(Float64List.bytesPerElement, _getFloat64, _setFloat64);

double _getFloat64(int offset, ByteData data, Endian endian) =>
    data.getFloat64(offset, endian);
void _setFloat64(double value, int offset, ByteData data, Endian endian) =>
    data.setFloat64(offset, value, endian);

class FloatType extends BinaryType<double> {
  final int width;

  final double Function(int offset, ByteData data, Endian endian) getValue;
  final void Function(double value, int offset, ByteData data, Endian endian)
      setValue;

  final Endian endian;

  const FloatType(this.width, this.getValue, this.setValue,
      {this.endian = Endian.little});

  @override
  Uint8List encode(double input) {
    final result = Uint8List(width);
    setValue(input, 0, result.buffer.asByteData(), endian);
    return result;
  }

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
      onValue(type.getValue(0, buffer.buffer.asByteData(), type.endian));
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
    if (index != 0) throw 'pending float conversion';
  }
}

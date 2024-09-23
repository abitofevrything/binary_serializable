import 'dart:typed_data';

import 'package:binary_serializable/src/binary_conversion.dart';
import 'package:binary_serializable/src/binary_type.dart';

const uint8 = _Uint8Type();

const int8 = IntegerType(Int8List.bytesPerElement, _getInt8, _setInt8);

int _getInt8(int offset, ByteData data, Endian endian) => data.getInt8(offset);
void _setInt8(int value, int offset, ByteData data, Endian endian) =>
    data.setInt8(offset, value);

const uint16 = IntegerType(Uint16List.bytesPerElement, _getUint16, _setUint16);

int _getUint16(int offset, ByteData data, Endian endian) =>
    data.getUint16(offset, endian);
void _setUint16(int value, int offset, ByteData data, Endian endian) =>
    data.setUint16(offset, value, endian);

const int16 = IntegerType(Int16List.bytesPerElement, _getInt16, _setInt16);

int _getInt16(int offset, ByteData data, Endian endian) =>
    data.getInt16(offset, endian);
void _setInt16(int value, int offset, ByteData data, Endian endian) =>
    data.setInt16(offset, value, endian);

const uint32 = IntegerType(Uint32List.bytesPerElement, _getUint32, _setUint32);

int _getUint32(int offset, ByteData data, Endian endian) =>
    data.getUint32(offset, endian);
void _setUint32(int value, int offset, ByteData data, Endian endian) =>
    data.setUint32(offset, value, endian);

const int32 = IntegerType(Int32List.bytesPerElement, _getInt32, _setInt32);

int _getInt32(int offset, ByteData data, Endian endian) =>
    data.getInt32(offset, endian);
void _setInt32(int value, int offset, ByteData data, Endian endian) =>
    data.setInt32(offset, value, endian);

const uint64 = IntegerType(Uint64List.bytesPerElement, _getUint64, _setUint64);

int _getUint64(int offset, ByteData data, Endian endian) =>
    data.getUint64(offset, endian);
void _setUint64(int value, int offset, ByteData data, Endian endian) =>
    data.setUint64(offset, value, endian);

const int64 = IntegerType(Int64List.bytesPerElement, _getInt64, _setInt64);

int _getInt64(int offset, ByteData data, Endian endian) =>
    data.getInt64(offset, endian);
void _setInt64(int value, int offset, ByteData data, Endian endian) =>
    data.setInt64(offset, value, endian);

class IntegerType extends BinaryType<int> {
  final int width;

  final int Function(int offset, ByteData data, Endian endian) getValue;
  final void Function(int value, int offset, ByteData data, Endian endian)
      setValue;

  final Endian endian;

  const IntegerType(this.width, this.getValue, this.setValue,
      {this.endian = Endian.big});

  @override
  Uint8List encode(int input) {
    final result = Uint8List(width);
    setValue(input, 0, result.buffer.asByteData(), endian);
    return result;
  }

  @override
  BinaryConversion<int> startConversion(void Function(int) onValue) =>
      _IntegerConversion(this, onValue);
}

class _IntegerConversion extends BinaryConversion<int> {
  final IntegerType type;
  final Uint8List buffer;
  var index = 0;

  _IntegerConversion(this.type, super.onValue) : buffer = Uint8List(type.width);

  @override
  int add(Uint8List data) {
    if (index == 0 && data.length >= type.width) {
      onValue(type.getValue(
        data.offsetInBytes,
        data.buffer.asByteData(),
        type.endian,
      ));
      return type.width;
    } else if (index + data.length >= type.width) {
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
  void addAll(Uint8List data) {
    // Make sure we have no data left in [buffer].
    var consumed = add(data);

    final wholeElementCount = (data.length - consumed) ~/ type.width;
    final buffer = data.buffer.asByteData(data.offsetInBytes + consumed);
    for (int i = 0; i < wholeElementCount; i++) {
      onValue(type.getValue(i * type.width, buffer, type.endian));
    }

    // Add any remaining data.
    add(Uint8List.sublistView(data, consumed + wholeElementCount * type.width));
  }

  @override
  void flush() {
    if (index != 0) throw 'pending integer conversion';
  }
}

class _Uint8Type extends BinaryType<int> {
  const _Uint8Type();

  @override
  Uint8List encode(input) => Uint8List(1)..[0] = input;

  @override
  BinaryConversion<int> startConversion(void Function(int p1) onValue) =>
      _Uint8Conversion(onValue);
}

class _Uint8Conversion extends BinaryConversion<int> {
  _Uint8Conversion(super.onValue);

  @override
  int add(Uint8List data) {
    if (data.isEmpty) return 0;
    onValue(data[0]);
    return 1;
  }

  @override
  void addAll(Uint8List data) {
    for (final value in data) {
      onValue(value);
    }
  }

  @override
  void flush() {}
}

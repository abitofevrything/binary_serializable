import 'dart:typed_data';

import 'package:binary_serializable/src/binary_conversion.dart';
import 'package:binary_serializable/src/binary_type.dart';

/// A [BinaryType] for [int]s encoded as unsigned 8-bit integers.
const uint8 = _Uint8Type();

/// A [BinaryType] for [int]s encoded as two's complement 8-bit integers.
const int8 = IntegerType(Int8List.bytesPerElement, _getInt8, _setInt8);

int _getInt8(int offset, ByteData data, Endian endian) => data.getInt8(offset);
void _setInt8(int value, int offset, ByteData data, Endian endian) =>
    data.setInt8(offset, value);

/// A [BinaryType] for [int]s encoded as unsigned 16-bit integers.
const uint16 = IntegerType(Uint16List.bytesPerElement, _getUint16, _setUint16);

int _getUint16(int offset, ByteData data, Endian endian) =>
    data.getUint16(offset, endian);
void _setUint16(int value, int offset, ByteData data, Endian endian) =>
    data.setUint16(offset, value, endian);

/// A [BinaryType] for [int]s encoded as two's complement 16-bit integers.
const int16 = IntegerType(Int16List.bytesPerElement, _getInt16, _setInt16);

int _getInt16(int offset, ByteData data, Endian endian) =>
    data.getInt16(offset, endian);
void _setInt16(int value, int offset, ByteData data, Endian endian) =>
    data.setInt16(offset, value, endian);

/// A [BinaryType] for [int]s encoded as unsigned 32-bit integers.
const uint32 = IntegerType(Uint32List.bytesPerElement, _getUint32, _setUint32);

int _getUint32(int offset, ByteData data, Endian endian) =>
    data.getUint32(offset, endian);
void _setUint32(int value, int offset, ByteData data, Endian endian) =>
    data.setUint32(offset, value, endian);

/// A [BinaryType] for [int]s encoded as two's complement 32-bit integers.
const int32 = IntegerType(Int32List.bytesPerElement, _getInt32, _setInt32);

int _getInt32(int offset, ByteData data, Endian endian) =>
    data.getInt32(offset, endian);
void _setInt32(int value, int offset, ByteData data, Endian endian) =>
    data.setInt32(offset, value, endian);

/// A [BinaryType] for [int]s encoded as unsigned 64-bit integers.
const uint64 = IntegerType(Uint64List.bytesPerElement, _getUint64, _setUint64);

int _getUint64(int offset, ByteData data, Endian endian) =>
    data.getUint64(offset, endian);
void _setUint64(int value, int offset, ByteData data, Endian endian) =>
    data.setUint64(offset, value, endian);

/// A [BinaryType] for [int]s encoded as two's complement 64-bit integers.
const int64 = IntegerType(Int64List.bytesPerElement, _getInt64, _setInt64);

int _getInt64(int offset, ByteData data, Endian endian) =>
    data.getInt64(offset, endian);
void _setInt64(int value, int offset, ByteData data, Endian endian) =>
    data.setInt64(offset, value, endian);

/// A [BinaryType] for [int]s.
///
/// This [BinaryType] is a generic implementation for all integer encodings. See
/// the constants declared in this library for instances of this type for
/// specific encodings.
class IntegerType extends BinaryType<int> {
  /// The width of this type's encoding, in bytes.
  final int width;

  /// The endianness of this type's encoding.
  final Endian endian;

  final int Function(int offset, ByteData data, Endian endian) _getValue;
  final void Function(int value, int offset, ByteData data, Endian endian)
      _setValue;

  /// Create a new [IntegerType].
  ///
  /// [_getValue] and [_setValue] are the functions used by this implementation
  /// to decode and encode integer values respectively by writing them into a
  /// [TypedData] buffer.
  ///
  /// [_setValue] is a function that takes an offset, a buffer and an endianness
  /// that returns the integer in the buffer at the specified offset read with
  /// the given endianness.
  ///
  /// [_setValue] is a function that takes a value, an offset, a buffer and an
  /// endianness that sets the value in the buffer at the specified offset to
  /// the given value encoded with the given endianness.
  const IntegerType(
    this.width,
    this._getValue,
    this._setValue, {
    this.endian = Endian.big,
  });

  @override
  Uint8List encode(int input) {
    final result = Uint8List(width);
    _setValue(input, 0, result.buffer.asByteData(), endian);
    return result;
  }

  @override
  void encodeInto(int input, BytesBuilder builder) =>
      builder.add(encode(input));

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
      onValue(type._getValue(
        data.offsetInBytes,
        data.buffer.asByteData(),
        type.endian,
      ));
      return type.width;
    } else if (index + data.length >= type.width) {
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
  void addAll(Uint8List data) {
    // Make sure we have no data left in [buffer].
    var consumed = add(data);

    final wholeElementCount = (data.length - consumed) ~/ type.width;
    final buffer = data.buffer.asByteData(data.offsetInBytes + consumed);
    for (int i = 0; i < wholeElementCount; i++) {
      onValue(type._getValue(i * type.width, buffer, type.endian));
    }

    // Add any remaining data.
    add(data.buffer.asUint8List(
      data.offsetInBytes + consumed + wholeElementCount * type.width,
    ));
  }

  @override
  void flush() {
    if (index != 0) throw StateError('Pending integer conversion');
  }
}

/// A specialized implementation of [BinaryType] for uint8.
///
/// We can achieve better efficiency than [IntegerType], since any input data
/// always contains at least one uint8, so there is no need for an intermediate
/// state buffer.
class _Uint8Type extends BinaryType<int> {
  const _Uint8Type();

  @override
  void encodeInto(int input, BytesBuilder builder) => builder.addByte(input);

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

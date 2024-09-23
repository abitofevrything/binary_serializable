import 'dart:typed_data';

import 'package:binary_serializable/src/binary_conversion.dart';
import 'package:binary_serializable/src/binary_type.dart';

/// A [BinaryType] for reading buffers of a given length.
///
/// This type does not validate the length of buffers it encodes.
class BufferType extends BinaryType<Uint8List> {
  /// The length of the buffer to read.
  final int length;

  /// Create a new [BufferType] for a specified [length].
  const BufferType(this.length);

  @override
  Uint8List encode(Uint8List input) => input;

  @override
  BinaryConversion<Uint8List> startConversion(
          void Function(Uint8List p1) onValue) =>
      BufferConversion(length, onValue);
}

/// A [BinaryConversion] that produces a buffer containing a set amount of
/// bytes.
class BufferConversion extends BinaryConversion<Uint8List> {
  /// The number of bytes to read into the buffer.
  final int length;

  final BytesBuilder _builder = BytesBuilder(copy: false);

  /// Create a new [BufferConversion].
  BufferConversion(this.length, super.onValue);

  @override
  int add(Uint8List data) {
    if (_builder.length + data.length >= length) {
      final taken = Uint8List.sublistView(data, 0, length - _builder.length);
      _builder.add(taken);
      onValue(_builder.takeBytes());
      return taken.length;
    } else {
      _builder.add(data);
      return data.length;
    }
  }

  @override
  void flush() {
    if (_builder.isNotEmpty) {
      throw StateError('Flushed while converting buffer');
    }
  }
}

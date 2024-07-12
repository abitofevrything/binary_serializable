import 'dart:typed_data';

import 'package:binary_serializable/src/binary_conversion.dart';
import 'package:binary_serializable/src/binary_type.dart';

class BufferType extends BinaryType<Uint8List> {
  final int length;

  const BufferType(this.length) : assert(length > 0);

  @override
  Uint8List encode(Uint8List input) => input;

  @override
  BinaryConversion<Uint8List> startConversion(
          void Function(Uint8List p1) onValue) =>
      BufferConversion(length, onValue);
}

class BufferConversion extends BinaryConversion<Uint8List> {
  final int length;

  final BytesBuilder _builder = BytesBuilder();

  BufferConversion(this.length, super.onValue) : assert(length > 0);

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
    if (_builder.isNotEmpty) throw 'flushed while converting buffer';
  }
}

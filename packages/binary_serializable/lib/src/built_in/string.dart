import 'dart:convert';
import 'dart:typed_data';

import 'package:binary_serializable/src/binary_conversion.dart';
import 'package:binary_serializable/src/binary_type.dart';

const utf8String = NullTerminatedStringType(utf8);

const asciiString = NullTerminatedStringType(ascii);

const latin1String = NullTerminatedStringType(latin1);

class NullTerminatedStringType extends BinaryType<String> {
  final Codec<String, List<int>> codec;

  const NullTerminatedStringType(this.codec);

  @override
  Uint8List encode(String input) {
    final content = codec.encode(input);
    return Uint8List(content.length + 1)..setAll(0, content);
  }

  @override
  BinaryConversion<String> startConversion(void Function(String p1) onValue) =>
      _NullTerminatedStringConversion(this, onValue);
}

class _NullTerminatedStringConversion extends BinaryConversion<String> {
  final NullTerminatedStringType type;
  final BytesBuilder builder = BytesBuilder();

  _NullTerminatedStringConversion(this.type, super.onValue);

  @override
  int add(Uint8List data) {
    final nullIndex = data.indexOf(0);
    if (nullIndex == -1) {
      builder.add(data);
      return data.length;
    }

    builder.add(Uint8List.sublistView(data, 0, nullIndex));

    onValue(type.codec.decode(builder.takeBytes()));

    return nullIndex + 1;
  }

  @override
  void flush() {
    if (builder.isNotEmpty) throw 'pending null terminated string conversion';
  }
}

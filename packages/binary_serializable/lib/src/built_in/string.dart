import 'dart:convert';
import 'dart:typed_data';

import 'package:binary_serializable/src/binary_conversion.dart';
import 'package:binary_serializable/src/binary_type.dart';

/// A [BinaryType] for UTF-8 [String]s encoded with a null-terminating byte.
const utf8String = NullTerminatedStringType(utf8);

/// A [BinaryType] for ASCII [String]s encoded with a null-terminating byte.
const asciiString = NullTerminatedStringType(ascii);

/// A [BinaryType] for ISO Latin 1 [String]s encoded with a null-terminating
/// byte.
const latin1String = NullTerminatedStringType(latin1);

/// A [BinaryType] for [String]s encoded with a null-terminating byte.
///
/// This [BinaryType] is a generic implementation for all string encodings. See
/// the constants declared in this library for instances of this type for
/// specific encodings.
class NullTerminatedStringType extends BinaryType<String> {
  /// The [Codec] used to decode the [String] from the bytes read.
  final Codec<String, List<int>> codec;

  /// Create a new [NullTerminatedStringType].
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
    if (builder.isNotEmpty) {
      throw StateError('Pending null terminated string conversion');
    }
  }
}

import 'package:binary_serializable/binary_serializable.dart';
import 'package:meta/meta.dart';

/// {@template magic}
/// A [BinaryType] that verifies that a
/// [magic header](https://en.wikipedia.org/wiki/List_of_file_signatures)
/// matches the expected value.
///
/// This type simply echoes the value read, but throws an error during the
/// conversion if the bytes do not match the expected header.
/// {@endtemplate}
abstract class Magic extends BinaryType<Uint8List> {
  /// {@macro magic}
  const Magic();

  /// Create a new [Magic] that obtains the header bytes using the specified
  /// function.
  const factory Magic.fromFunction(Uint8List Function() provider) =
      _FunctionProvidedMagic;

  /// Called to obtain the expected magic bytes.
  @protected
  Uint8List getMagic();

  @override
  Uint8List encode(Uint8List input) => input;

  @override
  BinaryConversion<Uint8List> startConversion(
          void Function(Uint8List p1) onValue) =>
      _MagicConversion(this, onValue);
}

// ignore: missing_override_of_must_be_overridden
class _FunctionProvidedMagic extends Magic {
  final Uint8List Function() provider;

  const _FunctionProvidedMagic(this.provider);

  @override
  Uint8List getMagic() => provider();
}

class _MagicConversion extends BinaryConversion<Uint8List> {
  final Magic type;

  late final magic = type.getMagic();
  var index = 0;

  _MagicConversion(this.type, super.onValue);

  @override
  int add(Uint8List data) {
    var offset = 0;
    while (index < magic.length && offset < data.length) {
      if (magic[index] != data[offset]) {
        throw FormatException('Bad magic bytes');
      }

      offset++;
      index++;
    }

    if (index == magic.length) {
      onValue(magic);
      index = 0;
    }

    return offset;
  }

  @override
  void flush() {
    if (index != 0) {
      throw StateError('Flushed while reading magic');
    }
  }
}

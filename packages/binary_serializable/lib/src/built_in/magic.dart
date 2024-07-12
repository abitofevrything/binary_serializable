import 'package:binary_serializable/binary_serializable.dart';

abstract class Magic extends BinaryType<Uint8List> {
  const Magic();

  const factory Magic.fromFunction(Uint8List Function() provider) =
      _FunctionProvidedMagic;

  Uint8List getMagic();

  @override
  Uint8List encode(Uint8List input) => input;

  @override
  BinaryConversion<Uint8List> startConversion(
          void Function(Uint8List p1) onValue) =>
      _MagicConversion(this, onValue);
}

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
        throw 'bad magic bytes';
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
      throw 'flush while reading magic';
    }
  }
}

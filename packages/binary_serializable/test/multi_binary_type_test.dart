import 'package:binary_serializable/binary_serializable.dart';

import 'built_in/int_test.dart';
import 'harness.dart';

// ignore: missing_override_of_must_be_overridden
class _TestType extends MultiBinaryType<Uint8List, int> {
  _TestType({super.subtypes});

  @override
  int extractPrelude(Uint8List instance) => instance.length;

  @override
  BinaryConversion<int> startPreludeConversion(void Function(int p1) onValue) =>
      uint8.startConversion(onValue);
}

class _TestLengthPrefixedBufferType extends BinaryType<Uint8List> {
  final int length;

  _TestLengthPrefixedBufferType(this.length);

  @override
  void encodeInto(Uint8List input, BytesBuilder builder) {
    uint8.encodeInto(input.length, builder);
    builder.add(input);
  }

  @override
  BinaryConversion<Uint8List> startConversion(
          void Function(Uint8List) onValue) =>
      _LengthPrefixedBufferConversion(this, onValue);
}

class _LengthPrefixedBufferConversion
    extends CompositeBinaryConversion<Uint8List> {
  final _TestLengthPrefixedBufferType type;

  _LengthPrefixedBufferConversion(this.type, super.onValue);

  @override
  BinaryConversion startConversion() {
    return uint8.startConversion((length) {
      currentConversion = BufferConversion(type.length, (buffer) {
        if (length != type.length) throw 'mismatched length';

        onValue(buffer);
      });
    });
  }
}

final lengths = [
  for (int i = 0; i < 8; i++) 1 << i,
];

void main() {
  testBinaryType(
    'MultiBinaryType',
    _TestType(subtypes: {
      for (final length in lengths)
        length: _TestLengthPrefixedBufferType(length),
    }),
    generate: () {
      final length = lengths[randomInteger(0, lengths.length)];
      final result = Uint8List(length);
      for (int i = 0; i < result.length; i++) {
        result[i] = randomInteger(0, 256);
      }
      return result;
    },
  );
}

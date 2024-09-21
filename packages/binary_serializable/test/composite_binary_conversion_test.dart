import 'dart:math';

import 'package:binary_serializable/binary_serializable.dart';

import 'built_in/int_test.dart';
import 'built_in/string_test.dart';
import 'harness.dart';

class _TestType extends BinaryType<(int, String, bool)> {
  @override
  Uint8List encode(input) {
    final builder = BytesBuilder();
    builder.add(uint8.encode(input.$1));
    builder.add(utf8String.encode(input.$2));
    builder.add(BoolType().encode(input.$3));
    return builder.toBytes();
  }

  @override
  BinaryConversion<(int, String, bool)> startConversion(
          void Function((int, String, bool) p1) onValue) =>
      _TestConversion(onValue);
}

class _TestConversion extends CompositeBinaryConversion<(int, String, bool)> {
  _TestConversion(super.onValue);

  @override
  BinaryConversion startConversion() {
    return uint8.startConversion((i) {
      currentConversion = utf8String.startConversion((s) {
        currentConversion = BoolType().startConversion((b) {
          onValue((i, s, b));
        });
      });
    });
  }
}

void main() {
  testBinaryType(
    'CompositeBinaryType',
    _TestType(),
    generate: () => (
      randomInteger(0, 256),
      randomString(),
      Random().nextBool(),
    ),
  );
}

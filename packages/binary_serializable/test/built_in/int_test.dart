import 'dart:math';

import 'package:binary_serializable/binary_serializable.dart';

import '../harness.dart';

final _random = Random();

int randomInteger(int min, int max) {
  final range = max - min;
  return min + _random.nextInt(range);
}

void main() {
  testBinaryType(
    'uint8',
    uint8,
    generate: () => randomInteger(0, 1 << 8),
  );

  testBinaryType(
    'int8',
    int8,
    generate: () => randomInteger(-1 << 7, 1 << 7),
  );

  testBinaryType(
    'uint16',
    uint16,
    generate: () => randomInteger(0, 1 << 16),
  );

  testBinaryType(
    'int16',
    int16,
    generate: () => randomInteger(-1 << 15, 1 << 15),
  );

  testBinaryType(
    'uint32',
    uint32,
    generate: () => randomInteger(0, 1 << 32),
  );

  testBinaryType(
    'int32',
    int32,
    generate: () => randomInteger(-1 << 31, 1 << 31),
  );

  testBinaryType(
    'uint64',
    uint64,
    generate: () {
      final lower = _random.nextInt(1 << 32);
      final upper = _random.nextInt(1 << 32);

      return (upper << 32) | lower;
    },
  );

  testBinaryType(
    'int64',
    int64,
    generate: () {
      final lower = _random.nextInt(1 << 32);
      final upper = _random.nextInt(1 << 32);

      return (upper << 32) | lower;
    },
  );
}

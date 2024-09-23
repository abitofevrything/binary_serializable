import 'dart:math';

import 'package:binary_serializable/binary_serializable.dart';

import '../../test/built_in/int_test.dart';
import '../harness.dart';

final _random = Random();

void main() {
  // Limit types encoded as a small amount of bytes to 10MB due to significant
  // overhead in storing Uint8Lists with only one element.

  benchmarkBinaryType(
    'uint8',
    uint8,
    maxCount: 100 * oneMegabyte,
    generate: () => randomInteger(0, 1 << 8),
  );

  benchmarkBinaryType(
    'int8',
    int8,
    maxCount: 100 * oneMegabyte,
    generate: () => randomInteger(-1 << 7, 1 << 7),
  );

  benchmarkBinaryType(
    'uint16',
    uint16,
    maxCount: 200 * oneMegabyte,
    generate: () => randomInteger(0, 1 << 16),
  );

  benchmarkBinaryType(
    'int16',
    int16,
    maxCount: 200 * oneMegabyte,
    generate: () => randomInteger(-1 << 15, 1 << 15),
  );

  benchmarkBinaryType(
    'uint32',
    uint32,
    generate: () => randomInteger(0, 1 << 32),
  );

  benchmarkBinaryType(
    'int32',
    int32,
    generate: () => randomInteger(-1 << 31, 1 << 31),
  );

  benchmarkBinaryType(
    'uint64',
    uint64,
    generate: () {
      final lower = _random.nextInt(1 << 32);
      final upper = _random.nextInt(1 << 32);

      return (upper << 32) | lower;
    },
  );

  benchmarkBinaryType(
    'int64',
    int64,
    generate: () {
      final lower = _random.nextInt(1 << 32);
      final upper = _random.nextInt(1 << 32);

      return (upper << 32) | lower;
    },
  );
}

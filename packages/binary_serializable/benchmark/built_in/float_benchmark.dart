import 'dart:typed_data';

import 'package:binary_serializable/binary_serializable.dart';

import '../../test/built_in/int_test.dart';
import '../harness.dart';

void main() {
  benchmarkBinaryType(
    'float32',
    float32,
    generate: () {
      double result;
      do {
        final buffer = Uint32List(1).buffer.asByteData();
        buffer.setUint32(0, randomInteger(0, 1 << 32));
        result = buffer.getFloat32(0);
      } while (result.isNaN);
      return result;
    },
  );

  benchmarkBinaryType(
    'float64',
    float64,
    generate: () {
      double result;
      do {
        final buffer = Uint64List(1).buffer.asByteData();
        buffer.setUint32(0, randomInteger(0, 1 << 32));
        buffer.setUint32(1, randomInteger(0, 1 << 32));
        result = buffer.getFloat64(0);
      } while (result.isNaN);
      return result;
    },
  );
}

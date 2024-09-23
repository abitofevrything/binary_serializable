import 'dart:math';

import 'package:binary_serializable/binary_serializable.dart';

import '../harness.dart';

void main() {
  benchmarkBinaryType(
    'BoolType',
    BoolType(),
    maxCount: 100 * oneMegabyte,
    generate: () => Random().nextBool(),
  );
}

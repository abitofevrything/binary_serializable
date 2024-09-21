import 'dart:math';

import 'package:binary_serializable/binary_serializable.dart';

import '../harness.dart';

void main() {
  testBinaryType(
    'BoolType',
    BoolType(),
    generate: () => Random().nextBool(),
  );
}

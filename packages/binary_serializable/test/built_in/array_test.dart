import 'package:binary_serializable/binary_serializable.dart';

import '../harness.dart';
import 'int_test.dart';

const lengths = [1, 10, 100, 1000, 256, 1024];

void main() {
  for (final length in lengths) {
    testBinaryType(
      'ArrayType ($length)',
      ArrayType(length, uint8),
      generate: () => List.generate(length, (_) => randomInteger(0, 256)),
    );
  }
}

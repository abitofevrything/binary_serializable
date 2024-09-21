import 'package:binary_serializable/binary_serializable.dart';

import '../harness.dart';
import 'int_test.dart';

void main() {
  testBinaryType(
    'LengthPrefixedListType',
    LengthPrefixedListType(uint8, uint8),
    generate: () => List.generate(
      randomInteger(0, 256),
      (_) => randomInteger(0, 256),
    ),
  );
}

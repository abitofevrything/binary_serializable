import 'package:binary_serializable/binary_serializable.dart';

import '../harness.dart';
import 'int_test.dart';

List<T> generateRandomList<T>(int length, T Function() generate) =>
    List.generate(
      length,
      (_) => generate(),
    );

void main() {
  testBinaryType(
    'LengthPrefixedListType',
    LengthPrefixedListType(uint8, uint8),
    generate: () =>
        generateRandomList(randomInteger(0, 256), () => randomInteger(0, 256)),
  );
}

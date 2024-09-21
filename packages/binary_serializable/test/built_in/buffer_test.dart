import 'package:binary_serializable/binary_serializable.dart';

import '../harness.dart';
import 'int_test.dart';

const lengths = [1, 10, 100, 1000, 256, 1024];

void main() {
  for (final length in lengths) {
    testBinaryType(
      'BufferType ($length)',
      BufferType(length),
      generate: () {
        final list = Uint8List(length);
        for (int i = 0; i < list.length; i++) {
          list[i] = randomInteger(0, 256);
        }
        return list;
      },
    );
  }
}

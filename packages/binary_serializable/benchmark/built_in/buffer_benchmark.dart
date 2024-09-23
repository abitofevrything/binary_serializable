import 'package:binary_serializable/binary_serializable.dart';

import '../../test/built_in/int_test.dart';
import '../harness.dart';

const lengths = [1, 10, 100, 1000, 256, 1024];

void main() {
  for (final length in lengths) {
    benchmarkBinaryType(
      'BufferType ($length)',
      BufferType(length),
      maxCount: length < 100 ? 100 * oneMegabyte : null,
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

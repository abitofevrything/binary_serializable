import 'package:binary_serializable/binary_serializable.dart';

import '../../test/built_in/string_test.dart';
import '../harness.dart';

void main() {
  benchmarkBinaryType(
    'utf8String',
    utf8String,
    generate: () => randomString(),
  );

  benchmarkBinaryType(
    'latin1String',
    latin1String,
    generate: () => randomString(),
  );

  benchmarkBinaryType(
    'asciiString',
    asciiString,
    generate: () => randomString(),
  );
}

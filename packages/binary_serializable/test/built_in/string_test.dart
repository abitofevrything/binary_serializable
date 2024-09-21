import 'package:binary_serializable/binary_serializable.dart';

import '../harness.dart';
import 'int_test.dart';

const alphabet = r"'"
    r'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!"$%^&*()_-=+[]{};:@#~,.<>/?\|`';

String randomString() {
  final buffer = StringBuffer();
  final length = randomInteger(0, 256);
  for (int i = 0; i < length; i++) {
    buffer.write(alphabet[randomInteger(0, alphabet.length)]);
  }
  return buffer.toString();
}

void main() {
  testBinaryType(
    'utf8String',
    utf8String,
    generate: () => randomString(),
  );

  testBinaryType(
    'asciiString',
    asciiString,
    generate: () => randomString(),
  );

  testBinaryType(
    'latin1String',
    latin1String,
    generate: () => randomString(),
  );
}

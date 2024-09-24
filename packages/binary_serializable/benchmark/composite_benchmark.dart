import 'dart:math';

import 'package:binary_serializable/binary_serializable.dart';

import '../test/built_in/int_test.dart';
import '../test/built_in/length_prefixed_list_test.dart';
import '../test/built_in/string_test.dart';
import 'harness.dart';

final random = Random();

Composite1 generateComposite1() => Composite1(
      randomInteger(0, 1 << 32),
      generateComposite2(),
      generateComposite4(),
    );

Composite2 generateComposite2() => Composite2(
      random.nextBool(),
      generateComposite3(),
      randomString(),
      randomString(),
      randomString(),
      randomString(),
    );

var depth = 0;

Composite3 generateComposite3() {
  depth++;

  final result = Composite3(generateRandomList(
    randomInteger(0, 10 - depth),
    generateComposite3,
  ));

  depth--;

  return result;
}

Composite4 generateComposite4() => Composite4(
      f1: randomString(),
      f2: List.generate(5, (_) => randomInteger(0, 256)),
    );

void main() {
  benchmarkBinaryType(
    'CompositeBinaryType',
    Composite1Type(),
    generate: generateComposite1,
  );
}

class Composite1 {
  final int f1;

  final Composite2 f2;

  final Composite4 f3;

  Composite1(this.f1, this.f2, this.f3);
}

class Composite2 {
  final bool f1;

  final Composite3 f2;

  final String f3, f4, f5, f6;

  Composite2(this.f1, this.f2, this.f3, this.f4, this.f5, this.f6);
}

class Composite3 {
  final List<Composite3> f1;

  Composite3(this.f1);
}

class Composite4 {
  final String f1;

  final List<int> f2;

  Composite4({required this.f1, required this.f2});
}

// Generated with binary_serializable_generator

class Composite1Type extends BinaryType<Composite1> {
  const Composite1Type();

  @override
  Uint8List encode(Composite1 input) {
    final builder = BytesBuilder(copy: false);
    builder.add(uint64.encode(input.f1));
    builder.add(const Composite2Type().encode(input.f2));
    builder.add(const Composite4Type().encode(input.f3));
    return builder.takeBytes();
  }

  @override
  BinaryConversion<Composite1> startConversion(
          void Function(Composite1) onValue) =>
      _Composite1Conversion(
        this,
        onValue,
      );
}

class _Composite1Conversion extends CompositeBinaryConversion<Composite1> {
  _Composite1Conversion(
    this.type,
    super.onValue,
  );

  final Composite1Type type;

  @override
  BinaryConversion startConversion() {
    return uint64.startConversion((f1) {
      currentConversion = const Composite2Type().startConversion((f2) {
        currentConversion = const Composite4Type().startConversion((f3) {
          final instance = Composite1(
            f1,
            f2,
            f3,
          );
          onValue(instance);
        });
      });
    });
  }
}

class Composite2Type extends BinaryType<Composite2> {
  const Composite2Type();

  @override
  Uint8List encode(Composite2 input) {
    final builder = BytesBuilder(copy: false);
    builder.add(const BoolType().encode(input.f1));
    builder.add(const Composite3Type().encode(input.f2));
    builder.add(asciiString.encode(input.f3));
    builder.add(asciiString.encode(input.f4));
    builder.add(asciiString.encode(input.f5));
    builder.add(asciiString.encode(input.f6));
    return builder.takeBytes();
  }

  @override
  BinaryConversion<Composite2> startConversion(
          void Function(Composite2) onValue) =>
      _Composite2Conversion(
        this,
        onValue,
      );
}

class _Composite2Conversion extends CompositeBinaryConversion<Composite2> {
  _Composite2Conversion(
    this.type,
    super.onValue,
  );

  final Composite2Type type;

  @override
  BinaryConversion startConversion() {
    return const BoolType().startConversion((f1) {
      currentConversion = const Composite3Type().startConversion((f2) {
        currentConversion = asciiString.startConversion((f3) {
          currentConversion = asciiString.startConversion((f4) {
            currentConversion = asciiString.startConversion((f5) {
              currentConversion = asciiString.startConversion((f6) {
                final instance = Composite2(
                  f1,
                  f2,
                  f3,
                  f4,
                  f5,
                  f6,
                );
                onValue(instance);
              });
            });
          });
        });
      });
    });
  }
}

class Composite3Type extends BinaryType<Composite3> {
  const Composite3Type();

  @override
  Uint8List encode(Composite3 input) {
    final builder = BytesBuilder(copy: false);
    builder.add(const LengthPrefixedListType(
      uint8,
      Composite3Type(),
    ).encode(input.f1));
    return builder.takeBytes();
  }

  BinaryConversion<Composite3> startConversion(
          void Function(Composite3) onValue) =>
      _Composite3Conversion(
        this,
        onValue,
      );
}

class _Composite3Conversion extends CompositeBinaryConversion<Composite3> {
  _Composite3Conversion(
    this.type,
    super.onValue,
  );

  final Composite3Type type;

  @override
  BinaryConversion startConversion() {
    return const LengthPrefixedListType(
      uint8,
      Composite3Type(),
    ).startConversion((f1) {
      final instance = Composite3(f1);
      onValue(instance);
    });
  }
}

class Composite4Type extends BinaryType<Composite4> {
  const Composite4Type();

  @override
  Uint8List encode(Composite4 input) {
    final builder = BytesBuilder(copy: false);
    builder.add(utf8String.encode(input.f1));
    builder.add(const ArrayType(
      5,
      uint64,
    ).encode(input.f2));
    return builder.takeBytes();
  }

  @override
  BinaryConversion<Composite4> startConversion(
          void Function(Composite4) onValue) =>
      _Composite4Conversion(
        this,
        onValue,
      );
}

class _Composite4Conversion extends CompositeBinaryConversion<Composite4> {
  _Composite4Conversion(
    this.type,
    super.onValue,
  );

  final Composite4Type type;

  @override
  BinaryConversion startConversion() {
    return utf8String.startConversion((f1) {
      currentConversion = const ArrayType(
        5,
        uint64,
      ).startConversion((f2) {
        final instance = Composite4(
          f1: f1,
          f2: f2,
        );
        onValue(instance);
      });
    });
  }
}

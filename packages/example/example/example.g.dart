// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

// **************************************************************************
// BinarySerializableGenerator
// **************************************************************************

// ignore_for_file: missing_override_of_must_be_overridden, duplicate_ignore

const exampleType = ExampleType();

class ExampleType extends BinaryType<Example> {
  const ExampleType();

  @override
  Uint8List encode(Example input) {
    final builder = BytesBuilder(copy: false);
    builder.add(uint8.encode(input.type));
    builder.add(const BufferType(256).encode(input.data));
    return builder.takeBytes();
  }

  @override
  BinaryConversion<Example> startConversion(void Function(Example) onValue) =>
      _ExampleConversion(onValue);
}

class _ExampleConversion extends CompositeBinaryConversion<Example> {
  _ExampleConversion(super.onValue);

  @override
  BinaryConversion startConversion() {
    return uint8.startConversion((type) {
      currentConversion = const BufferType(256).startConversion((data) {
        onValue(Example(type, data));
      });
    });
  }
}

// ignore_for_file: missing_override_of_must_be_overridden, duplicate_ignore

const baseType = BaseType();

class BaseType extends MultiBinaryType<Base, (int, int)> {
  const BaseType() : super(const {(2, 2): bType, (1, 0): aType});

  @override
  (int, int) extractPrelude(Base instance) => (instance.id, instance.subId);

  @override
  BinaryConversion<(int, int)> startPreludeConversion(
          void Function((int, int)) onValue) =>
      _BasePreludeConversion(onValue);
}

class _BasePreludeConversion extends CompositeBinaryConversion<(int, int)> {
  _BasePreludeConversion(super.onValue);

  @override
  BinaryConversion startConversion() {
    return int32.startConversion((concrete) {
      currentConversion = int32.startConversion((id) {
        currentConversion = int32.startConversion((concreteAgain) {
          currentConversion = int32.startConversion((subId) {
            onValue((id, subId));
          });
        });
      });
    });
  }
}

// ignore_for_file: missing_override_of_must_be_overridden, duplicate_ignore

const aType = AType();

class AType extends BinaryType<A> {
  const AType();

  @override
  Uint8List encode(A input) {
    final builder = BytesBuilder(copy: false);
    builder.add(int32.encode(input.concrete));
    builder.add(int32.encode(input.id));
    builder.add(int32.encode(input.concreteAgain));
    builder.add(int32.encode(input.subId));
    builder.add(int32.encode(input.aSpecific));
    return builder.takeBytes();
  }

  @override
  BinaryConversion<A> startConversion(void Function(A) onValue) =>
      _AConversion(onValue);
}

class _AConversion extends CompositeBinaryConversion<A> {
  _AConversion(super.onValue);

  @override
  BinaryConversion startConversion() {
    return int32.startConversion((concrete) {
      currentConversion = int32.startConversion((id) {
        currentConversion = int32.startConversion((concreteAgain) {
          currentConversion = int32.startConversion((subId) {
            currentConversion = int32.startConversion((aSpecific) {
              onValue(A(
                  concrete: concrete,
                  concreteAgain: concreteAgain,
                  aSpecific: aSpecific));
            });
          });
        });
      });
    });
  }
}

// ignore_for_file: missing_override_of_must_be_overridden, duplicate_ignore

const bType = BType();

class BType extends MultiBinaryType<B, (int, int, int)> {
  const BType() : super(const {(2, 2, 3): cType, (2, 2, 4): dType});

  @override
  (int, int, int) extractPrelude(B instance) =>
      (instance.id, instance.subId, instance.bId);

  @override
  BinaryConversion<(int, int, int)> startPreludeConversion(
          void Function((int, int, int)) onValue) =>
      _BPreludeConversion(onValue);
}

class _BPreludeConversion extends CompositeBinaryConversion<(int, int, int)> {
  _BPreludeConversion(super.onValue);

  @override
  BinaryConversion startConversion() {
    return int32.startConversion((concrete) {
      currentConversion = int32.startConversion((id) {
        currentConversion = int32.startConversion((concreteAgain) {
          currentConversion = int32.startConversion((subId) {
            currentConversion = int32.startConversion((bSpecific) {
              currentConversion = int32.startConversion((bId) {
                onValue((id, subId, bId));
              });
            });
          });
        });
      });
    });
  }
}

// ignore_for_file: missing_override_of_must_be_overridden, duplicate_ignore

const cType = CType();

class CType extends BinaryType<C> {
  const CType();

  @override
  Uint8List encode(C input) {
    final builder = BytesBuilder(copy: false);
    builder.add(int32.encode(input.concrete));
    builder.add(int32.encode(input.id));
    builder.add(int32.encode(input.concreteAgain));
    builder.add(int32.encode(input.subId));
    builder.add(int32.encode(input.bSpecific));
    builder.add(int32.encode(input.bId));
    return builder.takeBytes();
  }

  @override
  BinaryConversion<C> startConversion(void Function(C) onValue) =>
      _CConversion(onValue);
}

class _CConversion extends CompositeBinaryConversion<C> {
  _CConversion(super.onValue);

  @override
  BinaryConversion startConversion() {
    return int32.startConversion((concrete) {
      currentConversion = int32.startConversion((id) {
        currentConversion = int32.startConversion((concreteAgain) {
          currentConversion = int32.startConversion((subId) {
            currentConversion = int32.startConversion((bSpecific) {
              currentConversion = int32.startConversion((bId) {
                onValue(C(
                    concrete: concrete,
                    concreteAgain: concreteAgain,
                    bSpecific: bSpecific));
              });
            });
          });
        });
      });
    });
  }
}

// ignore_for_file: missing_override_of_must_be_overridden, duplicate_ignore

const dType = DType();

class DType extends BinaryType<D> {
  const DType();

  @override
  Uint8List encode(D input) {
    final builder = BytesBuilder(copy: false);
    builder.add(int32.encode(input.concrete));
    builder.add(int32.encode(input.id));
    builder.add(int32.encode(input.concreteAgain));
    builder.add(int32.encode(input.subId));
    builder.add(int32.encode(input.bSpecific));
    builder.add(int32.encode(input.bId));
    builder.add(int32.encode(input.ddddd));
    return builder.takeBytes();
  }

  @override
  BinaryConversion<D> startConversion(void Function(D) onValue) =>
      _DConversion(onValue);
}

class _DConversion extends CompositeBinaryConversion<D> {
  _DConversion(super.onValue);

  @override
  BinaryConversion startConversion() {
    return int32.startConversion((concrete) {
      currentConversion = int32.startConversion((id) {
        currentConversion = int32.startConversion((concreteAgain) {
          currentConversion = int32.startConversion((subId) {
            currentConversion = int32.startConversion((bSpecific) {
              currentConversion = int32.startConversion((bId) {
                currentConversion = int32.startConversion((ddddd) {
                  onValue(D(
                      concrete: concrete,
                      concreteAgain: concreteAgain,
                      bSpecific: bSpecific,
                      ddddd: ddddd));
                });
              });
            });
          });
        });
      });
    });
  }
}

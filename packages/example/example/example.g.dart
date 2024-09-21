// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

// **************************************************************************
// BinarySerializableGenerator
// **************************************************************************

// ignore_for_file: missing_override_of_must_be_overridden, duplicate_ignore

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
      _ExampleConversion(
        this,
        onValue,
      );
}

class _ExampleConversion extends CompositeBinaryConversion<Example> {
  _ExampleConversion(
    this.type,
    super.onValue,
  );

  final ExampleType type;

  @override
  BinaryConversion startConversion() {
    return uint8.startConversion((type) {
      currentConversion = const BufferType(256).startConversion((data) {
        final instance = Example(
          type,
          data,
        );
        onValue(instance);
      });
    });
  }
}

// ignore_for_file: missing_override_of_must_be_overridden, duplicate_ignore

class BaseType extends MultiBinaryType<Base, (int, int)> {
  const BaseType([super.subtypes = BaseType.defaultSubtypes]);

  static const Map<(int, int), BinaryType<Base>> defaultSubtypes = {
    (
      1,
      0,
    ): AType(),
    (
      2,
      2,
    ): BType(),
  };

  @override
  (int, int) extractPrelude(Base instance) => (
        instance.id,
        instance.subId,
      );

  @override
  BinaryConversion<(int, int)> startPreludeConversion(
          void Function((int, int)) onValue) =>
      _BasePreludeConversion(
        this,
        onValue,
      );
}

class _BasePreludeConversion extends CompositeBinaryConversion<(int, int)> {
  _BasePreludeConversion(
    this.type,
    super.onValue,
  );

  final BaseType type;

  @override
  BinaryConversion startConversion() {
    return int32.startConversion((concrete) {
      currentConversion = int32.startConversion((id) {
        currentConversion = int32.startConversion((concreteAgain) {
          currentConversion = int32.startConversion((subId) {
            onValue((
              id,
              subId,
            ));
          });
        });
      });
    });
  }
}

// ignore_for_file: missing_override_of_must_be_overridden, duplicate_ignore

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
  BinaryConversion<A> startConversion(void Function(A) onValue) => _AConversion(
        this,
        onValue,
      );
}

class _AConversion extends CompositeBinaryConversion<A> {
  _AConversion(
    this.type,
    super.onValue,
  );

  final AType type;

  @override
  BinaryConversion startConversion() {
    return int32.startConversion((concrete) {
      currentConversion = int32.startConversion((id) {
        currentConversion = int32.startConversion((concreteAgain) {
          currentConversion = int32.startConversion((subId) {
            currentConversion = int32.startConversion((aSpecific) {
              final instance = A(
                concrete: concrete,
                concreteAgain: concreteAgain,
                aSpecific: aSpecific,
              );
              if (instance.id != id) {
                throw 'parsed field id does not match predefined value';
              }

              if (instance.subId != subId) {
                throw 'parsed field subId does not match predefined value';
              }

              onValue(instance);
            });
          });
        });
      });
    });
  }
}

// ignore_for_file: missing_override_of_must_be_overridden, duplicate_ignore

class BType extends MultiBinaryType<B, (int, int, int)> {
  const BType([super.subtypes = BType.defaultSubtypes]);

  static const Map<(int, int, int), BinaryType<B>> defaultSubtypes = {
    (
      2,
      2,
      3,
    ): CType(),
    (
      2,
      2,
      4,
    ): DType(),
  };

  @override
  (int, int, int) extractPrelude(B instance) => (
        instance.id,
        instance.subId,
        instance.bId,
      );

  @override
  BinaryConversion<(int, int, int)> startPreludeConversion(
          void Function((int, int, int)) onValue) =>
      _BPreludeConversion(
        this,
        onValue,
      );
}

class _BPreludeConversion extends CompositeBinaryConversion<(int, int, int)> {
  _BPreludeConversion(
    this.type,
    super.onValue,
  );

  final BType type;

  @override
  BinaryConversion startConversion() {
    return int32.startConversion((concrete) {
      currentConversion = int32.startConversion((id) {
        currentConversion = int32.startConversion((concreteAgain) {
          currentConversion = int32.startConversion((subId) {
            currentConversion = int32.startConversion((bSpecific) {
              currentConversion = int32.startConversion((bId) {
                onValue((
                  id,
                  subId,
                  bId,
                ));
              });
            });
          });
        });
      });
    });
  }
}

// ignore_for_file: missing_override_of_must_be_overridden, duplicate_ignore

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
  BinaryConversion<C> startConversion(void Function(C) onValue) => _CConversion(
        this,
        onValue,
      );
}

class _CConversion extends CompositeBinaryConversion<C> {
  _CConversion(
    this.type,
    super.onValue,
  );

  final CType type;

  @override
  BinaryConversion startConversion() {
    return int32.startConversion((concrete) {
      currentConversion = int32.startConversion((id) {
        currentConversion = int32.startConversion((concreteAgain) {
          currentConversion = int32.startConversion((subId) {
            currentConversion = int32.startConversion((bSpecific) {
              currentConversion = int32.startConversion((bId) {
                final instance = C(
                  concrete: concrete,
                  concreteAgain: concreteAgain,
                  bSpecific: bSpecific,
                );
                if (instance.id != id) {
                  throw 'parsed field id does not match predefined value';
                }

                if (instance.subId != subId) {
                  throw 'parsed field subId does not match predefined value';
                }

                if (instance.bId != bId) {
                  throw 'parsed field bId does not match predefined value';
                }

                onValue(instance);
              });
            });
          });
        });
      });
    });
  }
}

// ignore_for_file: missing_override_of_must_be_overridden, duplicate_ignore

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
  BinaryConversion<D> startConversion(void Function(D) onValue) => _DConversion(
        this,
        onValue,
      );
}

class _DConversion extends CompositeBinaryConversion<D> {
  _DConversion(
    this.type,
    super.onValue,
  );

  final DType type;

  @override
  BinaryConversion startConversion() {
    return int32.startConversion((concrete) {
      currentConversion = int32.startConversion((id) {
        currentConversion = int32.startConversion((concreteAgain) {
          currentConversion = int32.startConversion((subId) {
            currentConversion = int32.startConversion((bSpecific) {
              currentConversion = int32.startConversion((bId) {
                currentConversion = int32.startConversion((ddddd) {
                  final instance = D(
                    concrete: concrete,
                    concreteAgain: concreteAgain,
                    bSpecific: bSpecific,
                    ddddd: ddddd,
                  );
                  if (instance.id != id) {
                    throw 'parsed field id does not match predefined value';
                  }

                  if (instance.subId != subId) {
                    throw 'parsed field subId does not match predefined value';
                  }

                  if (instance.bId != bId) {
                    throw 'parsed field bId does not match predefined value';
                  }

                  onValue(instance);
                });
              });
            });
          });
        });
      });
    });
  }
}

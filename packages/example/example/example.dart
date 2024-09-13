import 'package:binary_serializable/binary_serializable.dart';

part 'example.g.dart';

@BinarySerializable()
class Example {
  @uint8
  final int type;

  @BufferType(256)
  final Uint8List data;

  Example(this.type, this.data);
}

@BinarySerializable()
abstract base class Base {
  @int32
  final int concrete;

  @int32
  int get id;

  @int32
  final int concreteAgain;

  @int32
  int get subId;

  Base({required this.concrete, required this.concreteAgain});
}

@BinarySerializable()
final class A extends Base {
  @override
  int get id => 1;

  @override
  int get subId => 0;

  @int32
  final int aSpecific;

  A({
    required super.concrete,
    required super.concreteAgain,
    required this.aSpecific,
  });
}

@BinarySerializable()
abstract base class B extends Base {
  @override
  int get id => 2;

  @int32
  final int bSpecific;

  @override
  int get subId => 2;

  @int32
  int get bId;

  B({
    required super.concrete,
    required super.concreteAgain,
    required this.bSpecific,
  });
}

@BinarySerializable()
final class C extends B {
  @override
  int get bId => 3;

  C({
    required super.concrete,
    required super.concreteAgain,
    required super.bSpecific,
  });
}

@BinarySerializable()
final class D extends B {
  @override
  int get bId => 4;

  @int32
  final int ddddd;

  D({
    required super.concrete,
    required super.concreteAgain,
    required super.bSpecific,
    required this.ddddd,
  });
}

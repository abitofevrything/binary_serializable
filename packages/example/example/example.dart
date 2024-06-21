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

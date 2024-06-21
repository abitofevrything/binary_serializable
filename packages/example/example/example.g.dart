// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

// **************************************************************************
// BinarySerializableGenerator
// **************************************************************************

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
        currentConversion = initialConversion;
      });
    });
  }
}

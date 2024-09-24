# binary_serializable_generator

Code generation for [`binary_serializable`](https://pub.dev/packages/binary_serializable)'s BinaryTypes.

## Installation

Install `binary_serializable` as a regular dependency, as well as `binary_serializable_generator` and `build_runner` as dev dependencies.

```bash
$ dart pub add binary_serializable
$ dart pub add -d binary_serializable_generator build_runner
```

## Usage

Import `package:binary_serializable/binary_serializable.dart` and annotate your classes with `BinarySerializable` to generate a `BinaryType` for that class. Fields annotated with subtypes of `BinaryType` will be serialized in the generated type.

```dart
import 'package:binary_serializable/binary_serializable.dart';

part 'example.g.dart'; // Replace with file_name.g.dart - build_runner will generate the code into this file.

@BinarySerializable()
class Example {
  @uint64
  final int id;

  @utf8String
  final String name;

  @LengthPrefixedListType(uint8, utf8String)
  final List<String> tags;

  Example(this.id, this.name, this.tags);
}
```

Then, run `dart run build_runner build` and `binary_serializable_generator` will generate the following type in `file_name.g.dart`:

```dart
class ExampleType extends BinaryType<Example> {
  const ExampleType();

  @override
  Uint8List encode(Example input) {
    final builder = BytesBuilder(copy: false);
    builder.add(uint64.encode(input.id));
    builder.add(utf8String.encode(input.name));
    builder.add(const LengthPrefixedListType(
      uint8,
      utf8String,
    ).encode(input.tags));
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
    return uint64.startConversion((id) {
      currentConversion = utf8String.startConversion((name) {
        currentConversion = const LengthPrefixedListType(
          uint8,
          utf8String,
        ).startConversion((tags) {
          final instance = Example(
            id,
            name,
            tags,
          );
          onValue(instance);
        });
      });
    });
  }
}
```

## Advanced usage

### Custom constructors

`binary_serializable_generator` will default to the class's default (unnamed) constructor if applied on the class. You may specify a custom constructor by annotating that constructor instead of the class with `BinarySerializable`, with the following restrictions in mind:
- Any constructor parameter must have a field annotated with a `BinaryType` with the same name.
- All fields in the class annotated with `BinaryType` will be serialized in the order they appear in the class, regardless of whether the constructor requires them or not. Fields not present in the constructor will be parsed and discarded.

### Type parameters

Classes annotated with `BinarySerializable` may have type parameters, in which case `binary_serializable_generator` will add a corresponding parameter to the generated `BinaryType` to specify the `BinaryType` to use for that type parameter.

Fields depending on a type parameter may use the special `Generic` binary type, which will be replaced by the corresponding parameter in the generated code.

For example, here is a class with two type parameters and the associated generated code:

```dart
@BinarySerializable()
class GenericType<T, U> {
  @Generic('T')
  final T genericField;

  @LengthPrefixedListType(uint8, Generic('U'))
  final List<U> genericList;

  GenericType(this.genericField, this.genericList);
}

class GenericTypeType<T, U> extends BinaryType<GenericType<T, U>> {
  const GenericTypeType(
    this.genericTypeU,
    this.genericTypeT,
  );

  final BinaryType<U> genericTypeU;

  final BinaryType<T> genericTypeT;

  @override
  Uint8List encode(GenericType<T, U> input) {
    final builder = BytesBuilder(copy: false);
    builder.add(genericTypeT.encode(input.genericField));
    builder.add(LengthPrefixedListType(
      uint8,
      genericTypeU,
    ).encode(input.genericList));
    return builder.takeBytes();
  }

  @override
  BinaryConversion<GenericType<T, U>> startConversion(
          void Function(GenericType<T, U>) onValue) =>
      _GenericTypeConversion(
        this,
        onValue,
      );
}

class _GenericTypeConversion<T, U>
    extends CompositeBinaryConversion<GenericType<T, U>> {
  _GenericTypeConversion(
    this.type,
    super.onValue,
  );

  final GenericTypeType<T, U> type;

  @override
  BinaryConversion startConversion() {
    return type.genericTypeT.startConversion((genericField) {
      currentConversion = LengthPrefixedListType(
        uint8,
        type.genericTypeU,
      ).startConversion((genericList) {
        final instance = GenericType<T, U>(
          genericField,
          genericList,
        );
        onValue(instance);
      });
    });
  }
}
```

### Abstract classes

`binary_serializable_generator` can also generate `BinaryType`s for abstract classes by using a [`MultiBinaryType`](https://pub.dev/documentation/binary_serializable/latest/binary_serializable/MultiBinaryType-class.html).

The generator will automatically detect subtypes of the target class annotated with `BinarySerializable()` that override the prelude fields with fixed getters and register them as subtypes in the `MultiBinaryConversion`. The subtypes must be in scope for the target class to be detected.

For subtypes out of scope of the target class or that do not override the prelude fields with a fixed getter, the generated `BinaryType` can be instantiated at runtime with custom subtypes passed as an optional parameter to the constructor. The automatically detected subtypes can be accessed using the static `defaultSubtypes` getter, which allows you to easily extend the set of subtypes:

```dart
final type = GeneratedType({
  ...GeneratedType.defaultSubtypes,
  prelude1: customSubtype1,
  prelude2: customSubtype2,
  // ...
});
```

For example, here is an abstract class with two subtypes and the generated `BinaryType`:
```dart
@BinarySerializable()
abstract class Message {
  @uint8
  int get id;
}

@BinarySerializable()
class StringMessage extends Message {
  @override
  int get id => 2;

  @utf8String
  final String data;

  StringMessage(this.data);
}

@BinarySerializable()
class IntegerMessage extends Message {
  @override
  int get id => 1;

  @int64
  final int data;

  IntegerMessage(this.data);
}

class MessageType extends MultiBinaryType<Message, int> {
  const MessageType([super.subtypes = MessageType.defaultSubtypes]);

  static const Map<int, BinaryType<Message>> defaultSubtypes = {
    2: StringMessageType(),
    1: IntegerMessageType(),
  };

  @override
  int extractPrelude(Message instance) => instance.id;

  @override
  BinaryConversion<int> startPreludeConversion(void Function(int) onValue) =>
      _MessagePreludeConversion(
        this,
        onValue,
      );
}

class _MessagePreludeConversion extends CompositeBinaryConversion<int> {
  _MessagePreludeConversion(
    this.type,
    super.onValue,
  );

  final MessageType type;

  @override
  BinaryConversion startConversion() {
    return uint8.startConversion((id) {
      onValue(id);
    });
  }
}
```

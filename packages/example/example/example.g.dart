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

// ignore_for_file: missing_override_of_must_be_overridden, duplicate_ignore

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

// ignore_for_file: missing_override_of_must_be_overridden, duplicate_ignore

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

// ignore_for_file: missing_override_of_must_be_overridden, duplicate_ignore

class StringMessageType extends BinaryType<StringMessage> {
  const StringMessageType();

  @override
  Uint8List encode(StringMessage input) {
    final builder = BytesBuilder(copy: false);
    builder.add(uint8.encode(input.id));
    builder.add(utf8String.encode(input.data));
    return builder.takeBytes();
  }

  @override
  BinaryConversion<StringMessage> startConversion(
          void Function(StringMessage) onValue) =>
      _StringMessageConversion(
        this,
        onValue,
      );
}

class _StringMessageConversion
    extends CompositeBinaryConversion<StringMessage> {
  _StringMessageConversion(
    this.type,
    super.onValue,
  );

  final StringMessageType type;

  @override
  BinaryConversion startConversion() {
    return uint8.startConversion((id) {
      currentConversion = utf8String.startConversion((data) {
        final instance = StringMessage(data);
        if (instance.id != id) {
          throw 'parsed field id does not match predefined value';
        }

        onValue(instance);
      });
    });
  }
}

// ignore_for_file: missing_override_of_must_be_overridden, duplicate_ignore

class IntegerMessageType extends BinaryType<IntegerMessage> {
  const IntegerMessageType();

  @override
  Uint8List encode(IntegerMessage input) {
    final builder = BytesBuilder(copy: false);
    builder.add(uint8.encode(input.id));
    builder.add(int64.encode(input.data));
    return builder.takeBytes();
  }

  @override
  BinaryConversion<IntegerMessage> startConversion(
          void Function(IntegerMessage) onValue) =>
      _IntegerMessageConversion(
        this,
        onValue,
      );
}

class _IntegerMessageConversion
    extends CompositeBinaryConversion<IntegerMessage> {
  _IntegerMessageConversion(
    this.type,
    super.onValue,
  );

  final IntegerMessageType type;

  @override
  BinaryConversion startConversion() {
    return uint8.startConversion((id) {
      currentConversion = int64.startConversion((data) {
        final instance = IntegerMessage(data);
        if (instance.id != id) {
          throw 'parsed field id does not match predefined value';
        }

        onValue(instance);
      });
    });
  }
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:binary_serializable/src/binary_conversion.dart';
import 'package:meta/meta.dart';

abstract class BinaryType<T> extends Codec<T, List<int>> {
  const BinaryType();

  BinaryConversion<T> startConversion(void Function(T) onValue);

  @override
  @mustBeOverridden
  Uint8List encode(T input);

  @override
  Converter<List<int>, T> get decoder => _BinaryDecoder(this);

  Future<T> decodeStream(Stream<List<int>> stream) =>
      stream.transform(decoder).single;

  @override
  Converter<T, Uint8List> get encoder => _BinaryEncoder(this);
}

class _BinaryDecoder<T> extends Converter<List<int>, T> {
  final BinaryType<T> type;

  _BinaryDecoder(this.type);

  @override
  T convert(List<int> input) {
    if (input is! Uint8List) {
      input = Uint8List.fromList(input);
    }

    const sentinel = #_sentinel;

    Object? result = sentinel;
    void setResult(T value) => result = value;

    final conversion = type.startConversion(setResult);
    final consumed = conversion.add(input);
    conversion.flush();

    if (consumed != input.length) {
      throw 'too much data';
    }

    if (identical(sentinel, result)) {
      throw 'not enough data';
    }

    return result as T;
  }

  @override
  Sink<List<int>> startChunkedConversion(Sink<T> sink) {
    final conversion = type.startConversion(sink.add);

    return _CallbackSink(
      (data) {
        if (data is! Uint8List) {
          data = Uint8List.fromList(data);
        }

        conversion.addAll(data);
      },
      () {
        conversion.flush();
        sink.close();
      },
    );
  }
}

class _BinaryEncoder<T> extends Converter<T, Uint8List> {
  final BinaryType<T> type;

  _BinaryEncoder(this.type);

  @override
  Uint8List convert(T input) => type.encode(input);

  @override
  Sink<T> startChunkedConversion(Sink<Uint8List> sink) => _CallbackSink(
        (data) => sink.add(convert(data)),
        sink.close,
      );
}

class _CallbackSink<T> implements Sink<T> {
  final void Function(T) onData;
  final void Function() onClose;

  _CallbackSink(this.onData, this.onClose);

  @override
  void add(T data) => onData(data);

  @override
  void close() => onClose();
}

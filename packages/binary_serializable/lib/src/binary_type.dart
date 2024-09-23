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
    if (input is! Uint8List) input = Uint8List.fromList(input);

    late T result;
    var didConvert = false;

    final conversion = type.startConversion((value) {
      result = value;
      didConvert = true;
      assert(!didConvert, 'Already converted value');
    });

    final consumed = conversion.add(input);

    assert(consumed == input.length, 'Too much data to decode');
    assert(didConvert, 'Not enough data to decode');

    return result;
  }

  @override
  Sink<List<int>> startChunkedConversion(Sink<T> sink) =>
      _DecodeSink(sink, type);
}

class _BinaryEncoder<T> extends Converter<T, Uint8List> {
  final BinaryType<T> type;

  _BinaryEncoder(this.type);

  @override
  Uint8List convert(T input) => type.encode(input);

  @override
  Sink<T> startChunkedConversion(Sink<Uint8List> sink) =>
      _EncodeSink(sink, type);
}

class _DecodeSink<T> implements Sink<List<int>> {
  final BinaryConversion<T> conversion;
  final Sink<T> sink;

  _DecodeSink(this.sink, BinaryType<T> type)
      : conversion = type.startConversion(sink.add);

  @override
  void add(List<int> data) {
    if (data is! Uint8List) data = Uint8List.fromList(data);

    conversion.addAll(data);
  }

  @override
  void close() {
    conversion.flush();
    sink.close();
  }
}

class _EncodeSink<T> implements Sink<T> {
  final BinaryType<T> type;
  final Sink<Uint8List> sink;

  _EncodeSink(this.sink, this.type);

  @override
  void add(T data) => sink.add(type.encode(data));

  @override
  void close() => sink.close();
}

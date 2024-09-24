import 'dart:convert';
import 'dart:typed_data';

import 'package:binary_serializable/src/binary_conversion.dart';

/// {@template binary_type}
/// A [Codec] specialized for converting binary data.
///
/// [BinaryType] may be used as a supertype for any codec implementing binary
/// serialization and deserialization based on a [BinaryConversion] and an
/// [encodeInto] method.
///
/// To decode a stream of binary data, call [Stream.transform] with [decoder]
/// (`stream.transform(type.decoder)`).
/// {@endtemplate}
abstract class BinaryType<T> extends Codec<T, List<int>> {
  /// {@macro binary_type}
  const BinaryType();

  /// Start a new [BinaryConversion] that converts binary data to this type.
  ///
  /// See the [BinaryConversion.new] constructor for more information on this
  /// method's parameters.
  BinaryConversion<T> startConversion(void Function(T) onValue);

  @override
  Uint8List encode(T input) {
    final builder = BytesBuilder(copy: false);
    encodeInto(input, builder);
    return builder.takeBytes();
  }

  /// Encode [input] into [builder].
  ///
  /// The bytes representing [input] should be written to [builder] in the order
  /// they would be written
  void encodeInto(T input, BytesBuilder builder);

  /// Decode a single value from [stream].
  ///
  /// This is equivalent to calling
  /// `type.decode(await stream.expand((bytes) => bytes).toList())`, but may be
  /// significantly more efficient as the binary blob does not need to be stored
  /// in memory until all data is received.
  Future<T> decodeStream(Stream<List<int>> stream) =>
      stream.transform(decoder).single;

  @override
  Converter<List<int>, T> get decoder => _BinaryDecoder(this);

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
      assert(!didConvert, 'Already converted value');
      didConvert = true;
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

class _BinaryEncoder<T> extends Converter<T, Uint8List> {
  final BinaryType<T> type;

  _BinaryEncoder(this.type);

  @override
  Uint8List convert(T input) => type.encode(input);

  @override
  Sink<T> startChunkedConversion(Sink<Uint8List> sink) =>
      _EncodeSink(sink, type);
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

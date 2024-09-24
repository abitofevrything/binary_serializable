import 'dart:developer';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:binary_serializable/binary_serializable.dart';
import 'package:pretty_bytes/pretty_bytes.dart';

const sampleSize = 10000;

const oneGigabyte = 1000 * oneMegabyte;
const oneMegabyte = 1000 * oneKilobyte;
const oneKilobyte = 1000;

@pragma('vm:never-inline')
void _use(dynamic _) {}

class BinarySerializableBenchmark<T> extends BenchmarkBase {
  final int count;
  final BinaryType<T> type;
  final T Function() generate;

  BinarySerializableBenchmark(
    this.type,
    this.generate, {
    required this.count,
    required String name,
  }) : super(
          '$name (${prettyBytes(count.toDouble())})',
          emitter: BinarySerializableEmitter(count),
        );

  @override
  void exercise() => run();
}

class BinarySerializableEmitter extends ScoreEmitter {
  final int count;

  BinarySerializableEmitter(this.count);

  @override
  void emit(String testName, double value) {
    print(
        '$testName: ${(value / Duration.microsecondsPerMillisecond).toStringAsExponential(2)}ms (${prettyBytes(count / value * Duration.microsecondsPerSecond)}/s)');
  }
}

class EncodeBenchmark<T> extends BinarySerializableBenchmark {
  EncodeBenchmark(
    String name,
    super.type,
    super.generate, {
    required super.count,
  }) : super(name: '$name: encode    ');

  late final List<T> instances;

  @override
  void setup() {
    instances = List.generate(sampleSize, (_) => generate());
  }

  @override
  void run() {
    var encoded = 0;
    var index = 0;
    while (encoded < count) {
      encoded += type.encode(instances[index++ % instances.length]).length;
    }
  }
}

class DecodeBenchmark<T> extends BinarySerializableBenchmark {
  DecodeBenchmark(
    String name,
    super.type,
    super.generate, {
    required super.count,
  }) : super(name: '$name: decode    ');

  late final List<Uint8List> inputs;

  @override
  void setup() {
    inputs = [];
    var encodedCount = 0;
    while (encodedCount < count) {
      final encoded = type.encode(generate());
      inputs.add(encoded);
      encodedCount += encoded.length;
    }
  }

  @override
  void run() {
    for (final input in inputs) {
      _use(type.decode(input));
    }
  }
}

class DecodeAllBenchmark<T> extends BinarySerializableBenchmark {
  DecodeAllBenchmark(
    String name,
    super.type,
    super.generate, {
    required super.count,
  }) : super(name: '$name: decode all');

  late final Uint8List data;

  @override
  void setup() {
    final builder = BytesBuilder(copy: false);
    while (builder.length < count) {
      type.encodeInto(generate(), builder);
    }
    data = builder.takeBytes();
    debugger();
  }

  @override
  void run() {
    type.startConversion(_use).addAll(data);
  }
}

void benchmarkBinaryType<T>(
  String name,
  BinaryType<T> type, {
  required T Function() generate,
  int? maxCount,
}) async {
  for (final count in [
    oneKilobyte,
    oneMegabyte,
    10 * oneMegabyte,
    100 * oneMegabyte,
    oneGigabyte
  ]) {
    if (maxCount != null && count > maxCount) continue;

    EncodeBenchmark(name, type, generate, count: count).report();
    DecodeBenchmark(name, type, generate, count: count).report();
    DecodeAllBenchmark(name, type, generate, count: count).report();
  }
}

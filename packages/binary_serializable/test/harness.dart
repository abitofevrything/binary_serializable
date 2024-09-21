import 'package:binary_serializable/binary_serializable.dart';
import 'package:collection/collection.dart';
import 'package:test/test.dart';

const sampleSize = 10000;

void testBinaryType<T extends Object>(
  String name,
  BinaryType<T> type, {
  required T Function() generate,
  Map<T, Uint8List>? additionalSamples,
}) {
  group(name, () {
    const equality = DeepCollectionEquality();

    late final List<(T, Uint8List)> samples;
    setUpAll(() {
      samples = [
        ...?additionalSamples?.entries.map((e) => (e.key, e.value)),
        ...List.generate(sampleSize, (_) {
          final object = generate();
          return (object, type.encode(object));
        }),
      ];

      // Remove duplicate values.
      final seenValues = EqualitySet(equality);
      samples.removeWhere((pair) => !seenValues.add(pair.$1));

      samples.shuffle();
    });

    test('encode', () {
      for (final (instance, expected) in samples) {
        final encoded = type.encode(instance);
        expect(encoded, isNotEmpty);
        expect(encoded, equals(expected));
        expect(
          samples.where((v) => equality.equals(v.$2, expected)).length,
          equals(1),
        );
      }
    });

    test('decode', () {
      for (final (instance, encoded) in samples) {
        final decoded = type.decode(encoded);
        expect(decoded, equals(instance));
      }
    });

    test('decodeStream', () async {
      var chunkSize = 1;
      var continue_ = true;

      while (continue_) {
        continue_ = false;

        for (final (instance, encoded) in samples) {
          continue_ |= encoded.length > chunkSize;

          final decoded = await type.decodeStream(
            Stream.fromIterable(encoded.slices(chunkSize)),
          );

          expect(decoded, equals(instance));
        }

        chunkSize *= 10;
      }
    });

    group('conversion', () {
      test('calls onValue when a fully encoded value is passed', () {
        for (final (instance, encoded) in samples) {
          var wasCalled = false;
          final conversion = type.startConversion((value) {
            expect(value, equals(instance));
            wasCalled = true;
          });

          final consumed = conversion.add(encoded);
          expect(consumed, equals(encoded.length));
          expect(wasCalled, isTrue);
        }
      });

      test(
        'only partially reads the input when more than one value is passed',
        () {
          var previous = samples.first.$2;
          for (final (_, encoded) in samples.skip(1)) {
            final combined = (BytesBuilder()
                  ..add(previous)
                  ..add(encoded))
                .takeBytes();

            var callCount = 0;
            final conversion = type.startConversion((_) => callCount++);

            var consumed = conversion.add(combined);

            expect(callCount, equals(1));
            expect(consumed, equals(previous.length));

            consumed += conversion.add(combined.sublist(consumed));

            expect(callCount, equals(2));
            expect(consumed, equals(previous.length + encoded.length));

            previous = encoded;
          }
        },
      );

      test('waits for data if not enough is passed', () {
        for (final (instance, encoded) in samples) {
          final index = encoded.length ~/ 2;

          var wasCalled = false;
          final conversion = type.startConversion((value) {
            expect(value, equals(instance));
            wasCalled = true;
          });

          var consumed = conversion.add(encoded.sublist(0, index));
          expect(wasCalled, isFalse);
          expect(consumed, equals(index));

          consumed += conversion.add(encoded.sublist(index));
          expect(wasCalled, isTrue);
          expect(consumed, equals(encoded.length));
        }
      });

      test('can convert multiple values', () {
        T? lastValue;

        final conversion = type.startConversion((value) => lastValue = value);

        for (final (instance, encoded) in samples) {
          final consumed = conversion.add(encoded);
          expect(consumed, equals(encoded.length));
          expect(lastValue, equals(instance));
        }
      });

      test('addAll', () {
        final builder = BytesBuilder();
        for (final (_, encoded) in samples) {
          builder.add(encoded);
        }
        final bytes = builder.takeBytes();

        for (var chunkSize = 1;
            chunkSize < bytes.length * 10;
            chunkSize *= 10) {
          final allValues = EqualitySet(equality)
            ..addAll(samples.map((p) => p.$1));

          final conversion = type.startConversion((value) {
            expect(allValues.remove(value), isTrue);
          });

          for (final slice in bytes.slices(chunkSize)) {
            conversion.addAll(Uint8List.fromList(slice));
          }

          expect(allValues, isEmpty);
        }
      });

      group('flush', () {
        test('returns cleanly when not encoding a value', () {
          final conversion = type.startConversion((_) {});
          for (final (_, encoded) in samples) {
            conversion.add(encoded);

            expect(conversion.flush, returnsNormally);
          }
        });

        test('errors while converting value', () {
          for (final (_, encoded) in samples) {
            final conversion = type.startConversion((_) {});

            if (encoded.length == 1) continue;

            conversion.add(encoded.sublist(0, encoded.length - 1));

            expect(conversion.flush, throwsA(anything));
          }
        });
      });
    });
  });
}

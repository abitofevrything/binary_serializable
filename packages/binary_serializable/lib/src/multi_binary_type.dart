import 'package:binary_serializable/binary_serializable.dart';
import 'package:meta/meta.dart';

/// {@template multi_binary_type}
/// A [BinaryType] that selects one of multiple other [BinaryType]s to serialize
/// an object based on fields common to all possible types.
///
/// {@template prelude}
/// The set of fields common to all possible types that can be used to identify
/// the specific type to use is knows as the prelude. It may be a single value
/// (e.g `String type`) or multiple values in a record (e.g
/// `(int protocolVersion, String type)`).
///
/// The prelude type must correctly implement [Object.==] and [Object.hashCode].
/// {@endtemplate}
///
/// In practice, this is used to read an object header to determine its type
/// before then using a specific [BinaryType] to read type-specific fields.
/// {@endtemplate}
abstract class MultiBinaryType<T, U> extends BinaryType<T> {
  /// A mapping of known preludes to their corresponding types.
  ///
  /// {@macro prelude}
  ///
  /// This map is what connects an object's prelude to the specific type used to
  /// further encode or decode it.
  final Map<U, BinaryType<T>> subtypes;

  /// {@macro multi_binary_type}
  const MultiBinaryType(this.subtypes);

  /// Extract the prelude from a Dart object.
  ///
  /// This is used while encoding Dart objects to binary, to determine the
  /// specific [BinaryType] to use to encode the object properly.
  ///
  /// See [subtypes] for more information.
  @protected
  U extractPrelude(T instance);

  /// Start a conversion that reads the prelude from incoming binary data.
  ///
  /// This is used while decoding binary data to determine the specific
  /// [BinaryType] to use to decode the object properly.
  ///
  /// See [subtypes] for more information.
  @protected
  BinaryConversion<U> startPreludeConversion(void Function(U) onValue);

  @override
  Uint8List encode(input) {
    final prelude = extractPrelude(input);
    final subtype = subtypes[prelude];

    if (subtype == null) {
      throw 'No subtype matching $prelude found';
    }

    return subtype.encode(input);
  }

  @override
  BinaryConversion<T> startConversion(void Function(T p1) onValue) =>
      _MultiBinaryConversion(this, onValue);
}

class _MultiBinaryConversion<T, U> extends BinaryConversion<T> {
  MultiBinaryType<T, U> type;

  late final BinaryConversion<U> _preludeConversion =
      type.startPreludeConversion((prelude) {
    final subtype = type.subtypes[prelude];
    if (subtype == null) {
      throw 'no subtype matching $prelude found';
    }
    _currentConversion = subtype.startConversion(onValue);
  });

  late BinaryConversion _currentConversion = _preludeConversion;

  final BytesBuilder _preludeBytes = BytesBuilder(copy: false);

  _MultiBinaryConversion(this.type, super.onValue);

  @override
  void onValue(T value) {
    _currentConversion = _preludeConversion;
    super.onValue(value);
  }

  @override
  int add(Uint8List data) {
    var consumed = 0;

    if (identical(_currentConversion, _preludeConversion)) {
      consumed += _preludeConversion.add(data);
      _preludeBytes.add(Uint8List.sublistView(data, 0, consumed));

      if (identical(_currentConversion, _preludeConversion)) {
        if (consumed != data.length) {
          throw 'prelude conversion did not read entire input or emit a value';
        }
        return consumed;
      } else {
        // Since subtypes are also fully standalone [BinaryType]s, they expect
        // to receive a full object in binary form.
        //
        // This means we can't reuse the prelude we already parsed, and instead
        // have to copy the bytes we read as part of the prelude into the
        // subtype's conversion.

        final expectedConsumption = _preludeBytes.length;
        final actualConsumption =
            _currentConversion.add(_preludeBytes.takeBytes());

        // The subtype should be made up of at least the fields in the prelude,
        // so we expect it to read all the data we pass it.
        if (actualConsumption != expectedConsumption) {
          throw 'Conversion did not read entire prelude';
        }

        // Update the chunk so we don't add data we've already copied into the
        // subtype conversion again.
        data = Uint8List.sublistView(data, consumed);
      }
    }

    consumed += _currentConversion.add(data);
    return consumed;
  }

  @override
  void flush() {
    _currentConversion.flush();
  }
}

import 'dart:typed_data';

import 'package:meta/meta.dart';

/// An ongoing conversion of binary data to a Dart object.
///
/// A [BinaryConversion] consumes binary data received from calls to [add] or
/// [addAll] and converts it to a Dart object.
///
/// A [BinaryConversion] is never complete. Once a value is produced by the
/// conversion, it is started over and further calls to [add] and [addAll] start
/// building another object.
///
/// The conversion may be discarded at any time, though [flush] should be called
/// to ensure no object is currently being built.
abstract class BinaryConversion<T> {
  final void Function(T) _onValue;

  /// Create a [BinaryConversion] with the specified callback.
  ///
  /// The callback will be invoked whenever this conversion produces a value as
  /// a result of a call to [add] or [addAll].
  BinaryConversion(this._onValue);

  /// Add [data] to this conversion.
  ///
  /// If a call to [add] provides enough bytes to produce a value, [onValue]
  /// will be called with the created object.
  ///
  /// Calling [add] will never produce more than one value on this conversion's
  /// output. Multiple calls to [add] may therefore be needed to consume all of
  /// [data]. Use [addAll] if you want to consume all of [data].
  ///
  /// Returns the number of bytes of [data] consumed. This may be less than
  /// `data.length` if a value was converted. `data.length` is returned if no
  /// value was converted (more data needed) or if [data] contained exactly one
  /// value.
  int add(Uint8List data);

  /// Adds all of [data] to this conversion.
  ///
  /// If a call to [addAll] provides enough bytes to produce a value, [onValue]
  /// will be called with the created object. [onValue] may be called multiple
  /// times during a call to [addAll].
  ///
  /// Unlike [add], which may only consume part of [data] if a value is
  /// produced, this method always consumes all of [data].
  void addAll(Uint8List data) {
    var consumed = 0;
    while (consumed < data.length) {
      consumed += add(Uint8List.sublistView(data, consumed));
    }
  }

  /// Ensure this conversion is not currently deserializing a Dart object.
  ///
  /// This method will throw an error if called after an [add] or [addAll] call
  /// that did not produce a value. In other words, it asserts the conversion's
  /// internal state is "clean" and that no data will be lost by discarding the
  /// conversion instance.
  void flush();

  /// Called when the conversion produces a value in response to an [add] or
  /// [addAll] call.
  @protected
  void onValue(T value) => _onValue(value);
}

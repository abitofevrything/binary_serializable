import 'dart:typed_data';

import 'package:binary_serializable/src/binary_conversion.dart';
import 'package:meta/meta.dart';

/// A [BinaryConversion] that composes multiple [BinaryConversion]s to form a
/// composite object.
///
/// [CompositeBinaryConversion] may be used as a superclass for any class
/// implementing a [BinaryConversion] as sequentially passing data through
/// several other [BinaryConversion]s.
abstract class CompositeBinaryConversion<T> extends BinaryConversion<T> {
  late BinaryConversion _currentConversion = startConversion();
  bool _isFlushed = true;

  /// Sets the current conversion in response to another conversion producing a
  /// value.
  ///
  /// Should only be called in a [BinaryConversion]'s [onValue] callback.
  ///
  /// See [startConversion] for more information.
  @protected
  set currentConversion(BinaryConversion conversion) {
    _currentConversion = conversion;
    _isFlushed = false;
  }

  /// Create a new [CompositeBinaryConversion] with the given callback.
  CompositeBinaryConversion(super.onValue);

  /// Called when the conversion of a new object is started.
  ///
  /// This method should return the first conversion to run incoming bytes into.
  ///
  /// Once that first conversion produces a value, [currentConversion] should be
  /// set to the next conversion to run incoming bytes into, and this repeats
  /// until the last conversion needed to produce a value is created.
  ///
  /// Once the final conversion produces a value, subclasses should call
  /// [onValue] with the value computed from the sub-conversions, and this
  /// conversion's state will be reset.
  ///
  /// In practice, this method often is implemented as a series of nested
  /// [onValue] callbacks for the sub-conversions that capture the produced
  /// values as local variables:
  /// ```dart
  /// @override
  /// BinaryConversion startConversion() {
  ///   return uint8.startConversion((firstValue) {
  ///     currentConversion = utf8String.startConversion((secondValue) {
  ///       currentConversion = BoolType().startConversion((thirdValue) {
  ///         onValue((firstValue, secondValue, thirdValue));
  ///       });
  ///     });
  ///   });
  /// }
  /// ```
  @protected
  BinaryConversion startConversion();

  @override
  int add(Uint8List data) {
    var offset = 0;
    BinaryConversion previousConversion;

    do {
      previousConversion = _currentConversion;
      offset += _currentConversion.add(
        data.buffer.asUint8List(data.offsetInBytes + offset),
      );

      // _isFlushed is set when we produce a value.
      if (_isFlushed) return offset;
    } while (previousConversion != _currentConversion);

    assert(offset == data.length, 'Conversion did not consume all input');

    return offset;
  }

  @override
  void flush() {
    _currentConversion.flush();
    if (!_isFlushed) {
      throw StateError('Flushed while reading composite value');
    }
  }

  @override
  void onValue(T value) {
    super.onValue(value);
    _currentConversion = startConversion();
    _isFlushed = true;
  }
}

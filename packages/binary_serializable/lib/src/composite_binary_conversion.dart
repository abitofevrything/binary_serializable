import 'dart:typed_data';

import 'package:binary_serializable/src/binary_conversion.dart';

abstract class CompositeBinaryConversion<T> extends BinaryConversion<T> {
  late BinaryConversion _currentConversion = startConversion();
  bool _isFlushed = true;

  set currentConversion(BinaryConversion conversion) {
    _currentConversion = conversion;
    _isFlushed = false;
  }

  CompositeBinaryConversion(super.onValue);

  BinaryConversion startConversion();

  @override
  int add(Uint8List data) {
    var offset = 0;
    BinaryConversion previousConversion;

    do {
      previousConversion = _currentConversion;
      offset += _currentConversion.add(Uint8List.sublistView(data, offset));
      if (_isFlushed) return offset;
    } while (previousConversion != _currentConversion);

    if (offset != data.length) {
      throw 'conversion did not consume all input';
    }

    return offset;
  }

  @override
  void flush() {
    _currentConversion.flush();
    if (!_isFlushed) {
      throw 'flushed while reading composite value';
    }
  }

  @override
  void onValue(T value) {
    super.onValue(value);
    _currentConversion = startConversion();
    _isFlushed = true;
  }
}

import 'dart:typed_data';

import 'package:binary_serializable/src/binary_conversion.dart';

abstract class CompositeBinaryConversion<T> extends BinaryConversion<T> {
  late BinaryConversion _currentConversion = _initialConversion;
  late final _initialConversion = startConversion();

  set currentConversion(BinaryConversion conversion) =>
      _currentConversion = conversion;
  BinaryConversion get initialConversion => _initialConversion;

  CompositeBinaryConversion(super.onValue);

  @override
  int add(Uint8List data) {
    var offset = 0;
    do {
      offset += _currentConversion.add(Uint8List.sublistView(data, offset));
    } while (offset < data.length && _currentConversion != _initialConversion);
    return offset;
  }

  @override
  void flush() {
    _currentConversion.flush();
    if (_currentConversion != _initialConversion) {
      throw 'flush while converting composite value';
    }
  }

  BinaryConversion startConversion();
}

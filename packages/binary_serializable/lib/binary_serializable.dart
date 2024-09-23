/// Efficient binary serialization and deserialization, optimized for streams of binary data.
library;

export 'src/binary_conversion.dart';
export 'src/binary_serializable.dart';
export 'src/binary_type.dart';
export 'src/composite_binary_conversion.dart';
export 'src/multi_binary_type.dart';

export 'src/built_in/array.dart';
export 'src/built_in/bool.dart';
export 'src/built_in/float.dart';
export 'src/built_in/int.dart';
export 'src/built_in/length_prefixed_list.dart';
export 'src/built_in/string.dart';
export 'src/built_in/buffer.dart';

export 'dart:typed_data' show BytesBuilder, Uint8List;

## 0.3.0

- Fix a bug in CompositeBinaryConversion causing the input buffer to not be consumed properly.
- Allow subconverters in CompositeBinaryConversion to call onValue without consuming any data.
- Add MultiBinaryConversion.
- Add missing const constructors.

## 0.2.2

- Change default endianess for numeric types to big endian.

## 0.2.1

- Allow 0-length conversions.

## 0.2.0

- Added `BufferType`, `BufferConversion` and `CompositeBinaryConversion`

## 0.1.0

- Initial version.

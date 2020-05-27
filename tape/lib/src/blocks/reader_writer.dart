part of 'blocks.dart';

/// A more advanced writer for bytes that supports the following two modes:
/// - If you just call the write methods without an offset, it takes care of
///   allocating memory if necessary. It also internally maintains a cursor
///   position so that multiple consecutive calls to write result in all the
///   bytes getting sequentially written.
/// - If you pass an offset to a write method, it assumes you know what you're
///   doing. That means, no memory is allocated (the offset should be valid)
///   and the cursor is not advanced.
class Writer {
  Writer() {
    _data = ByteData.view(_buffer.buffer);
  }

  Uint8List get buffer => Uint8List.view(_buffer.buffer, 0, _cursor);
  Uint8List _buffer = Uint8List(256);

  /// A [ByteData] view of the [buffer].
  ByteData _data;

  /// The cursor offset in bytes.
  int get cursor => _cursor;
  int _cursor = 0;

  /// Makes sure that [numBytes] bytes can be written to the buffer and returns
  /// [numBytes] offset where to write those bytes. Also advances the cursor.
  int _reserve(int numBytes) {
    if (_buffer.length - _cursor < numBytes) {
      // We create a list that is 2-4 times larger than required.
      var newSize = _pow2roundup((_cursor + numBytes) * 2);
      var newBuffer = Uint8List(newSize);
      newBuffer.setRange(0, _cursor, _buffer);
      _buffer = newBuffer;
      _data = ByteData.view(_buffer.buffer);
    }

    final cursorBefore = _cursor;
    _cursor += numBytes;
    return cursorBefore;
  }

  int leaveSpace(int numBytes) => _reserve(numBytes);

  void writeUint8(int value, {int offset}) {
    offset ??= _reserve(1);
    _data.setUint8(offset, value);
  }

  void writeInt8(int value, {int offset}) {
    offset ??= _reserve(1);
    _data.setInt8(offset, value);
  }

  void writeUint16(int value, {int offset}) {
    offset ??= _reserve(2);
    _data.setUint16(offset, value);
  }

  void writeInt16(int value, {int offset}) {
    offset ??= _reserve(2);
    _data.setInt16(offset, value);
  }

  void writeUint32(int value, {int offset}) {
    offset ??= _reserve(4);
    _data.setUint32(offset, value);
  }

  void writeInt32(int value, {int offset}) {
    offset ??= _reserve(4);
    _data.setInt32(offset, value);
  }

  void writeUint64(int value, {int offset}) {
    offset ??= _reserve(8);
    _data.setUint64(offset, value);
  }

  void writeInt64(int value, {int offset}) {
    offset ??= _reserve(8);
    _data.setInt64(offset, value);
  }

  void writeFloat32(double value, {int offset}) {
    offset ??= _reserve(4);
    _data.setFloat32(offset, value);
  }

  void writeFloat64(double value, {int offset}) {
    offset ??= _reserve(8);
    _data.setFloat64(offset, value);
  }
}

/// A simple reader for bytes that also maintains a cursor position and allows
/// for jumping to arbitrary places.
class Reader {
  Reader(List<int> data)
      : _data = ByteData.view(Uint8List.fromList(data).buffer);

  final ByteData _data;

  int get cursor => _cursor;
  int _cursor = 0;

  int _reserve(int bytes) {
    final cursorBefore = _cursor;
    _cursor += bytes;
    return cursorBefore;
  }

  void jumpTo(int offset) => _cursor = offset;

  int readUint8() => _data.getUint8(_reserve(1));
  int readInt8() => _data.getInt8(_reserve(1));
  int readUint16() => _data.getUint16(_reserve(2));
  int readInt16() => _data.getInt16(_reserve(2));
  int readUint32() => _data.getUint32(_reserve(4));
  int readInt32() => _data.getInt32(_reserve(4));
  int readUint64() => _data.getUint64(_reserve(8));
  int readInt64() => _data.getInt64(_reserve(8));
  double readFloat32() => _data.getFloat32(_reserve(4));
  double readFloat64() => _data.getFloat64(_reserve(8));
}

int _pow2roundup(int x) {
  assert(x > 0);
  --x;
  x |= x >> 1;
  x |= x >> 2;
  x |= x >> 4;
  x |= x >> 8;
  x |= x >> 16;
  return x + 1;
}

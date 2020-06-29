part of '../blocks.dart';

/// A block that contains some bytes.
class BytesBlock implements Block {
  BytesBlock(this.bytes)
      : assert(bytes != null),
        assert(bytes.every((byte) => byte >= 0 && byte < 256),
            'All bytes need to be between 0 and 256 (0 <= bytes < 256).');

  final List<int> bytes;

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BytesBlock && _dce.equals(bytes, other.bytes);
  int get hashCode => runtimeType.hashCode ^ _dce.hash(bytes);

  String toString([int _]) =>
      'BytesBlock([${bytes.map((byte) => byte.toString()).join(', ')}])';
}

// An encoded [BytesBlock] looks like this:
// | num bytes | byte | byte | byte | ... |
// The number of bytes is encoded as an int64, the bytes as uint8s.

extension _BytesBlockWriter on _Writer {
  void writeBytesBlock(BytesBlock block) {
    writeInt64(block.bytes.length);
    block.bytes.forEach(writeUint8);
  }
}

extension _BytesBlockReader on _Reader {
  // TODO: We can probably make this lots more efficient by just returning a view of the actual ByteData. To be able to do that, we'd have the change the Reader signature though.
  BytesBlock readBytesBlock() {
    final length = readInt64();
    return BytesBlock([
      for (var i = 0; i < length; i++) readUint8(),
    ]);
  }
}

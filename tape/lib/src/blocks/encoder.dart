part of 'blocks.dart';

// Just like JSON, tape supports several primitive data types. To distinguish
// them from other Dart types that users might want to encode, they are called
// "blocks". Some blocks can contain other blocks.

// To encode complex types, they are first turned into a nested structure of
// blocks and these blocks are then encoded.
// then composed out of these primitive types. Because the tape-format is not
// intended to be human-readable that allows us optimizations in regard to
// encoding speed and length of the encoding. So, instead of relying on whole
// different formats for different types (like, enclosing strings in quotes),
// surrounding lists with [], we can simply give each primitive type a unique
// id. Here are ids of the primitive types (each id is ):
// rather than string-level, each primitive type has a one-byte
// The encoding format is as follows:

const blocks = _BlocksCodec();

class _BlocksCodec extends Codec<Object, List<int>> {
  const _BlocksCodec();

  @override
  get encoder => const _BlocksEncoder();

  @override
  get decoder => const _BlocksDecoder();
}

class _BlocksEncoder extends Converter<Block, List<int>> {
  const _BlocksEncoder();

  @override
  List<int> convert(Block input) => (Writer()..writeBlock(input)).buffer;
}

class _BlocksDecoder extends Converter<List<int>, Block> {
  const _BlocksDecoder();

  @override
  Block convert(List<int> input) => Reader(input).readBlock();
}

// An encoded generic [Block] looks like this:
// | block id | block |
// The block id is saved as a uint8.

const _blockIds = {
  TypedBlock: 0x00,
  FieldsBlock: 0x01,
  BytesBlock: 0x02,
  ListBlock: 0x03,
  IntBlock: 0x04,
  Uint8Block: 0x05,
  Uint16Block: 0x06,
  Uint32Block: 0x07,
  Int8Block: 0x08,
  Int16Block: 0x09,
  Int32Block: 0x0a,
  DoubleBlock: 0x0b,
  Float32Block: 0x0c,
  SafeBlock: 0x0d,
};

extension _BlockWriter on Writer {
  void writeBlock(Block block) {
    final type = block.runtimeType;
    final id = _blockIds[type] ?? (throw UnsupportedBlockError(block));
    writeUint8(id);
    if (block is TypedBlock) {
      writeTypedBlock(block);
    } else if (block is FieldsBlock) {
      writeFieldsBlock(block);
    } else if (block is BytesBlock) {
      writeBytesBlock(block);
    } else if (block is ListBlock) {
      writeListBlock(block);
    } else if (block is IntBlock) {
      writeIntBlock(block);
    } else if (block is Uint8Block) {
      writeUint8Block(block);
    } else if (block is Uint16Block) {
      writeUint16Block(block);
    } else if (block is Uint32Block) {
      writeUint32Block(block);
    } else if (block is Int8Block) {
      writeInt8Block(block);
    } else if (block is Int16Block) {
      writeInt16Block(block);
    } else if (block is Int32Block) {
      writeInt32Block(block);
    } else if (block is DoubleBlock) {
      writeDoubleBlock(block);
    } else if (block is Float32Block) {
      writeFloat32Block(block);
    }
  }
}

extension _BlockReader on Reader {
  Block readBlock() {
    final id = readUint8();
    final reader = {
      _blockIds[TypedBlock]: readTypedBlock,
      _blockIds[FieldsBlock]: readFieldsBlock,
      _blockIds[BytesBlock]: readBytesBlock,
      _blockIds[ListBlock]: readListBlock,
      _blockIds[IntBlock]: readIntBlock,
      _blockIds[Uint8Block]: readUint8Block,
      _blockIds[Uint16Block]: readUint16Block,
      _blockIds[Uint32Block]: readUint32Block,
      _blockIds[Int8Block]: readInt8Block,
      _blockIds[Int16Block]: readInt16Block,
      _blockIds[Int32Block]: readInt32Block,
      _blockIds[DoubleBlock]: readDoubleBlock,
      _blockIds[Float32Block]: readFloat32Block,
    }[id];
    return reader();
  }
}

// An encoded [TypedBlock] looks like this:
// | type id as int64 | child block |
// The type id is encoded as int64.

extension _TypedBlockWriter on Writer {
  void writeTypedBlock(TypedBlock block) {
    writeInt64(block.typeId);
    writeBlock(block.child);
  }
}

extension _TypedBlockReader on Reader {
  TypedBlock readTypedBlock() {
    return TypedBlock(
      typeId: readInt64(),
      child: readBlock(),
    );
  }
}

// An encoded [FieldBlock] looks like this:
// | num fields | field id | field value | field id | field value | ... |
// The number of fields and the field ids are encoded as uint32.

extension _FieldsBlockWriter on Writer {
  void writeFieldsBlock(FieldsBlock block) {
    final fields = block.fields.entries.toList();
    writeUint32(fields.length);

    for (final field in fields) {
      writeUint32(field.key);
      writeBlock(field.value);
    }
  }
}

extension _FieldsBlockReader on Reader {
  FieldsBlock readFieldsBlock() {
    final numFields = readUint32();
    return FieldsBlock({
      for (var i = 0; i < numFields; i++) readUint32(): readBlock(),
    });
  }
}

// An encoded [BytesBlock] looks like this:
// | num bytes | byte | byte | byte | ... |
// The number of bytes is encoded as a uint32, the bytes as uint8s.

extension _BytesBlockWriter on Writer {
  void writeBytesBlock(BytesBlock block) {
    writeUint32(block.bytes.length);
    block.bytes.forEach(writeUint8);
  }
}

extension _BytesBlockReader on Reader {
  // TODO: We can probably make this lots more efficient by just returning a view of the actual ByteData. To be able to do that, we'd have the change the Reader signature though.
  BytesBlock readBytesBlock() {
    final length = readUint32();
    return BytesBlock([
      for (var i = 0; i < length; i++) readUint8(),
    ]);
  }
}

// An encoded [ListBlock] looks like this:
// | length | item | item | ... |
// The length is encoded as a uint32.

extension _ListBlockWriter on Writer {
  void writeListBlock(ListBlock block) {
    writeUint32(block.items.length);
    block.items.forEach(writeBlock);
  }
}

extension _ListBlockReader on Reader {
  ListBlock readListBlock() {
    final length = readUint32();
    return ListBlock([
      for (var i = 0; i < length; i++) readBlock(),
    ]);
  }
}

// The int values are encoded as their direct binary representation:
// | value |

extension _IntBlocksWriter on Writer {
  void writeIntBlock(IntBlock block) => writeInt64(block.value);
  void writeUint8Block(Uint8Block block) => writeUint8(block.value);
  void writeUint16Block(Uint16Block block) => writeUint16(block.value);
  void writeUint32Block(Uint32Block block) => writeUint32(block.value);
  void writeInt8Block(Int8Block block) => writeInt8(block.value);
  void writeInt16Block(Int16Block block) => writeInt16(block.value);
  void writeInt32Block(Int32Block block) => writeInt32(block.value);
}

extension _IntBlocksReader on Reader {
  IntBlock readIntBlock() => IntBlock(readInt64());
  Uint8Block readUint8Block() => Uint8Block(readUint8());
  Uint16Block readUint16Block() => Uint16Block(readUint16());
  Uint32Block readUint32Block() => Uint32Block(readUint32());
  Int8Block readInt8Block() => Int8Block(readInt8());
  Int16Block readInt16Block() => Int16Block(readInt16());
  Int32Block readInt32Block() => Int32Block(readInt32());
}

// The double values are encoded as their direct binary representation:
// | value |

extension _DoubleBlocksWriter on Writer {
  void writeDoubleBlock(DoubleBlock block) => writeFloat64(block.value);
  void writeFloat32Block(Float32Block block) => writeFloat32(block.value);
}

extension _DoubleBlocksReader on Reader {
  DoubleBlock readDoubleBlock() => DoubleBlock(readFloat64());
  Float32Block readFloat32Block() => Float32Block(readFloat32());
}

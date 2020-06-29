part of '../blocks.dart';

@sealed
abstract class Block {
  const Block._();

  String toString([int indention]);
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

extension _BlockWriter on _Writer {
  void writeBlock(Block block) {
    final type = block.runtimeType;
    final id = _blockIds[type] ??
        (block is UnsupportedBlock
            ? throw UsedTheUnsupportedBlockError()
            : throw UnsupportedBlockError(block));
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
    } else if (block is SafeBlock) {
      writeSafeBlock(block);
    } else {
      assert(
        false,
        "This shouldn't happen because unsupported shouldn't have an id. "
        "So, we should have failed above.",
      );
    }
  }
}

extension _BlockReader on _Reader {
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
      _blockIds[SafeBlock]: readSafeBlock,
    }[id];
    if (reader == null) {
      throw UnsupportedBlockException(id);
    }
    return reader();
  }
}

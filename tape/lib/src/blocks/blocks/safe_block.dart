part of '../blocks.dart';

/// Saves the length of the [child] block so that if a block-level parsing error
/// occurs, we can skip the block. This is not intended to be used by consumers.
/// Instead, the `blocks` codec will automatically insert this block when it
/// encodes newly supported blocks. Similarly, it will also remove the
/// [SafeBlock] during decoding, replacing it either with its child or an
/// [UnsupportedBlock].
class SafeBlock implements Block {
  SafeBlock({@required this.child}) : assert(child != null);

  final Block child;

  bool operator ==(Object other) =>
      identical(this, other) || other is SafeBlock && child == other.child;
  int get hashCode => runtimeType.hashCode ^ child.hashCode;
}

/// Is produced during decoding if a [SafeBlock] contained an unsupported block.
/// Cannot be explicitly encoded.
class UnsupportedBlock implements Block {
  UnsupportedBlock(this.blockId) : assert(blockId != null);

  final int blockId;

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnsupportedBlock && blockId == other.blockId;
}

// An encoded [BytesBlock] looks like this:
// | num bytes | child |
// The number of bytes is encoded as a uint32.

extension _SafeBlockWriter on _Writer {
  void writeSafeBlock(SafeBlock block) {
    final lengthCursor = cursor;
    writeUint32(0);
    final cursorBefore = cursor;
    writeBlock(block.child);
    final cursorAfter = cursor;
    final length = cursorAfter - cursorBefore;
    jumpTo(lengthCursor);
    writeUint32(length);
    jumpTo(cursorAfter);
  }
}

extension _SafeBlockReader on _Reader {
  Block readSafeBlock() {
    final length = readUint32();
    if (length == 0) {
      // TODO: Throw exception – this is an invalid format
      return null;
    }
    final cursorBefore = cursor;
    try {
      return SafeBlock(child: readBlock());
    } on UnsupportedBlockException catch (e) {
      jumpTo(cursorBefore + length); // Jump after the block.
      return UnsupportedBlock(e.id);
    }
  }
}

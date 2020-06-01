part of '../blocks.dart';

/// Block that contains multiple other blocks.
class ListBlock implements Block {
  ListBlock(this.children) : assert(children != null);

  final List<Block> children;

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListBlock && _dce.equals(children, other.children);
  int get hashCode => runtimeType.hashCode ^ _dce.hash(children);
}

// An encoded [ListBlock] looks like this:
// | length | item | item | ... |
// The length is encoded as an int64.

extension _ListBlockWriter on _Writer {
  void writeListBlock(ListBlock block) {
    writeInt64(block.children.length);
    block.children.forEach(writeBlock);
  }
}

extension _ListBlockReader on _Reader {
  ListBlock readListBlock() {
    final length = readInt64();
    return ListBlock([
      for (var i = 0; i < length; i++) readBlock(),
    ]);
  }
}

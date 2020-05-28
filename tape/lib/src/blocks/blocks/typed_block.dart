part of '../blocks.dart';

/// Annotates the subtree with a [typeId] that indicates which [TapeAdapter] can
/// interpret the blocks.
class TypedBlock implements Block {
  TypedBlock({@required this.typeId, @required this.child})
      : assert(typeId != null),
        assert(child != null);

  final int typeId;
  final Block child;

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypedBlock && typeId == other.typeId && child == other.child;
  int get hashCode => runtimeType.hashCode ^ typeId.hashCode ^ child.hashCode;
}

// An encoded [TypedBlock] looks like this:
// | type id as int64 | child block |
// The type id is encoded as int64.

extension _TypedBlockWriter on _Writer {
  void writeTypedBlock(TypedBlock block) {
    writeInt64(block.typeId);
    writeBlock(block.child);
  }
}

extension _TypedBlockReader on _Reader {
  TypedBlock readTypedBlock() {
    return TypedBlock(
      typeId: readInt64(),
      child: readBlock(),
    );
  }
}

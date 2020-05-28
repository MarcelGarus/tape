part of '../blocks.dart';

class IntBlock implements Block {
  IntBlock(this.value) : assert(value != null);

  final int value;

  bool operator ==(Object other) =>
      identical(this, other) || other is IntBlock && value == other.value;
  int get hashCode => runtimeType.hashCode ^ value.hashCode;
}

// The int values are encoded as their direct binary representation:
// | value |

extension _IntBlocksWriter on _Writer {
  void writeIntBlock(IntBlock block) => writeInt64(block.value);
}

extension _IntBlocksReader on _Reader {
  IntBlock readIntBlock() => IntBlock(readInt64());
}
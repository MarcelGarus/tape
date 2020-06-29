part of '../blocks.dart';

class DoubleBlock implements Block {
  DoubleBlock(this.value) : assert(value != null);

  final double value;

  bool operator ==(Object other) =>
      identical(this, other) || other is DoubleBlock && value == other.value;
  int get hashCode => runtimeType.hashCode ^ value.hashCode;

  String toString([int _]) => 'DoubleBlock($value)';
}

// The double values are encoded as their direct binary representation:
// | value |

extension _DoubleBlocksWriter on _Writer {
  void writeDoubleBlock(DoubleBlock block) => writeFloat64(block.value);
}

extension _DoubleBlocksReader on _Reader {
  DoubleBlock readDoubleBlock() => DoubleBlock(readFloat64());
}

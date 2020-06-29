part of '../blocks.dart';

class Int32Block implements Block {
  Int32Block(this.value)
      : assert(value != null),
        assert(value >= -2147483648),
        assert(value < 2147483647);

  final int value;

  bool operator ==(Object other) =>
      identical(this, other) || other is Int32Block && value == other.value;
  int get hashCode => runtimeType.hashCode ^ value.hashCode;

  String toString([int _]) => 'Int32Block($value)';
}

extension _Int32BlocksWriter on _Writer {
  void writeInt32Block(Int32Block block) => writeInt32(block.value);
}

extension _Int32BlocksReader on _Reader {
  Int32Block readInt32Block() => Int32Block(readInt32());
}

part of '../blocks.dart';

class Int8Block implements Block {
  Int8Block(this.value)
      : assert(value != null),
        assert(value >= -128),
        assert(value < 128);

  final int value;

  bool operator ==(Object other) =>
      identical(this, other) || other is Int8Block && value == other.value;
  int get hashCode => runtimeType.hashCode ^ value.hashCode;
}

extension _Int8BlocksWriter on _Writer {
  void writeInt8Block(Int8Block block) => writeInt8(block.value);
}

extension _Int8BlocksReader on _Reader {
  Int8Block readInt8Block() => Int8Block(readInt8());
}

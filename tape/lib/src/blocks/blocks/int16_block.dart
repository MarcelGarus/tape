part of '../blocks.dart';

class Int16Block implements Block {
  Int16Block(this.value)
      : assert(value != null),
        assert(value >= -32768),
        assert(value < 32767);

  final int value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Int16Block && value == other.value;

  @override
  int get hashCode => runtimeType.hashCode ^ value.hashCode;

  @override
  String toString([int _]) => 'Int16Block($value)';
}

extension _Int16BlocksWriter on _Writer {
  void writeInt16Block(Int16Block block) => writeInt16(block.value);
}

extension _Int16BlocksReader on _Reader {
  Int16Block readInt16Block() => Int16Block(readInt16());
}

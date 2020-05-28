part of '../blocks.dart';

class Uint16Block implements Block {
  Uint16Block(this.value)
      : assert(value != null),
        assert(value >= 0),
        assert(value < 65536);

  final int value;

  bool operator ==(Object other) =>
      identical(this, other) || other is Uint16Block && value == other.value;
  int get hashCode => runtimeType.hashCode ^ value.hashCode;
}

extension _Uint16BlocksWriter on _Writer {
  void writeUint16Block(Uint16Block block) => writeUint16(block.value);
}

extension _Uint16BlocksReader on _Reader {
  Uint16Block readUint16Block() => Uint16Block(readUint16());
}

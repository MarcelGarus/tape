part of '../blocks.dart';

class Uint32Block implements Block {
  Uint32Block(this.value)
      : assert(value != null),
        assert(value >= 0),
        assert(value < 4294967296);

  final int value;

  bool operator ==(Object other) =>
      identical(this, other) || other is Uint32Block && value == other.value;
  int get hashCode => runtimeType.hashCode ^ value.hashCode;

  String toString([int _]) => 'Uint32Block($value)';
}

extension _Uint32BlocksWriter on _Writer {
  void writeUint32Block(Uint32Block block) => writeUint32(block.value);
}

extension _Uint32BlocksReader on _Reader {
  Uint32Block readUint32Block() => Uint32Block(readUint32());
}

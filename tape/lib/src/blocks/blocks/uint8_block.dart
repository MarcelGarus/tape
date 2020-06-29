part of '../blocks.dart';

class Uint8Block implements Block {
  Uint8Block(this.value)
      : assert(value != null),
        assert(value >= 0),
        assert(value < 256);

  final int value;

  bool operator ==(Object other) =>
      identical(this, other) || other is Uint8Block && value == other.value;
  int get hashCode => runtimeType.hashCode ^ value.hashCode;

  String toString([int _]) => 'Uint8Block($value)';
}

extension _Uint8BlocksWriter on _Writer {
  void writeUint8Block(Uint8Block block) => writeUint8(block.value);
}

extension _Uint8BlocksReader on _Reader {
  Uint8Block readUint8Block() => Uint8Block(readUint8());
}

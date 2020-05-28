part of '../blocks.dart';

class Float32Block implements Block {
  Float32Block(this.value) : assert(value != null);

  final double value;

  bool operator ==(Object other) =>
      identical(this, other) || other is Float32Block && value == other.value;
  int get hashCode => runtimeType.hashCode ^ value.hashCode;
}

extension _Float32BlocksWriter on _Writer {
  void writeFloat32Block(Float32Block block) => writeFloat32(block.value);
}

extension _Float32BlocksReader on _Reader {
  Float32Block readFloat32Block() => Float32Block(readFloat32());
}

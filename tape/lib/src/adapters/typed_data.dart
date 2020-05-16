/// Adapters for types from `dart:typed_data`.

part of 'adapters.dart';

class AdapterForUint8List extends AdapterFor<Uint8List> {
  const AdapterForUint8List();

  @override
  void write(TapeWriter writer, Uint8List list) {
    writer.writeUint32(list.length);
    list.forEach(writer.writeUint8);
  }

  @override
  Uint8List read(TapeReader reader) {
    final length = reader.readUint32();
    return Uint8List.fromList([
      for (var i = 0; i < length; i++) reader.readUint8(),
    ]);
  }
}

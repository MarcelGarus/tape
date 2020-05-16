part of 'adapters.dart';

// Custom types.

extension CustomTypeWriter on TapeWriter {
  void writeFieldId(int fieldId) => writeInt32(fieldId);
}

extension CustomTypeReader on TapeReader {
  int readFieldId() => readInt32();
}

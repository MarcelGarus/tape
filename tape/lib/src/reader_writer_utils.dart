part of 'tape.dart';

extension TypeIdWriter on TapeWriter {
  void writeTypeId(int fieldId) => writeInt64(fieldId);
}

extension TypeIdReader on TapeReader {
  int readTypeId() => readInt64();
}

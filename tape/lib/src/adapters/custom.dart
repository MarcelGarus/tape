/// Helper methods for custom adapters defined in other packages or in projects
/// by users. Most of these adapters are probably generated by `tape_generator`.
///
/// Custom types generated by `tape_generator` are layed out like this:
/// For every field, there's its id as defined in the corresponding `@TapeField`
/// annotation. These ids are saved as Uint32 values. Because Dart's `int`s are
/// 64bit, any valid positive integer number can be used as an id.

part of 'adapters.dart';

extension CustomTypeWriter on TapeWriter {
  void writeFieldId(int fieldId) => writeUint32(fieldId);
}

extension CustomTypeReader on TapeReader {
  int readFieldId() => readUint32();
}

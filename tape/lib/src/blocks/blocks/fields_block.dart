part of '../blocks.dart';

/// A block that contains multiple other blocks, each references by an id.
class FieldsBlock implements Block {
  FieldsBlock(this.fields)
      : assert(fields != null),
        assert(fields.keys.every((fieldId) => fieldId >= 0));

  final Map<int, Block> fields;

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FieldsBlock && _dce.equals(fields, other.fields);
  int get hashCode => runtimeType.hashCode ^ _dce.hash(fields);
}

// An encoded [FieldBlock] looks like this:
// | num fields | field id | field value | field id | field value | ... |
// The number of fields and the field ids are encoded as uint32.

extension _FieldsBlockWriter on _Writer {
  void writeFieldsBlock(FieldsBlock block) {
    final fields = block.fields.entries.toList();
    writeUint32(fields.length);

    for (final field in fields) {
      writeUint32(field.key);
      writeBlock(field.value);
    }
  }
}

extension _FieldsBlockReader on _Reader {
  FieldsBlock readFieldsBlock() {
    final numFields = readUint32();
    return FieldsBlock({
      for (var i = 0; i < numFields; i++) readUint32(): readBlock(),
    });
  }
}

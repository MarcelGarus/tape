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

  String toString([int indention = 0]) {
    final buffer = StringBuffer()..writeln('FieldsBlock({');
    for (final field in fields.entries) {
      buffer.writeln(
          '${' ' * indention}  ${field.key}: ${field.value.toString(indention + 1)},');
    }
    buffer.write('${'  ' * indention}})');
    return buffer.toString();
  }
}

// An encoded [FieldBlock] looks like this:
// | num fields | field id | field value | field id | field value | ... |
// The number of fields and the field ids are encoded as an int64.

extension _FieldsBlockWriter on _Writer {
  void writeFieldsBlock(FieldsBlock block) {
    final fields = block.fields.entries.toList();
    writeInt64(fields.length);

    for (final field in fields) {
      writeInt64(field.key);
      writeBlock(field.value);
    }
  }
}

extension _FieldsBlockReader on _Reader {
  FieldsBlock readFieldsBlock() {
    final numFields = readInt64();
    return FieldsBlock({
      for (var i = 0; i < numFields; i++) readInt64(): readBlock(),
    });
  }
}

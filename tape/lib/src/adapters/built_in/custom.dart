part of 'built_in.dart';

/// A snapshot of a class's field values.
class Fields {
  const Fields(this._fields);

  final Map<int, dynamic> _fields;
  Map<int, dynamic> toMap() => Map.from(_fields);
  List<Field> get fields =>
      _fields.entries.map((entry) => Field(entry.key, entry.value)).toList();

  T get<T>(int fieldId, {@required T orDefault}) {
    return _fields.containsKey(fieldId) ? _fields[fieldId] : orDefault;
  }
}

class Field<T> {
  Field(this.id, this.value);

  final int id;
  final T value;
}

/// [TapeClassAdapter]s can be extended to support serializing and
/// deserializing Dart objects of type [T].
@immutable
abstract class TapeClassAdapter<T> extends TapeAdapter<T, ClassBlock> {
  const TapeClassAdapter();

  Fields toFields(T object);
  T fromFields(Fields fields);

  T fromBlock(ClassBlock block) {
    final fields = Fields({
      for (final field in block.fields.entries)
        field.key: const BlockToObjectDecoder().convert(field.value),
    });
    return fromFields(fields);
  }

  ClassBlock toBlock(T object) {
    return ClassBlock(
      typeId: id,
      fields: {
        for (final field in toFields(object)._fields.entries)
          field.key: const ObjectToBlockEncoder().convert(field.value),
      },
    );
  }
}

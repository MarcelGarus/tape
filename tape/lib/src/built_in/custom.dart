import 'package:meta/meta.dart';

import '../adapters/adapters.dart';
import '../blocks/blocks.dart';

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

  bool contains(int fieldId) => _fields.containsKey(fieldId);
}

class Field<T> {
  Field(this.id, this.value);

  final int id;
  final T value;
}

/// [TapeClassAdapter]s can be extended to support serializing and
/// deserializing Dart objects of type [T].
@immutable
abstract class TapeClassAdapter<T> extends TapeAdapter<T> {
  const TapeClassAdapter();

  Fields toFields(T object);
  T fromFields(Fields fields);

  T fromBlock(Block block) {
    final fields = Fields({
      for (final field in block.as<FieldsBlock>().fields.entries)
        field.key: adapters.decode(field.value),
    });
    return fromFields(fields);
  }

  Block toBlock(T object) {
    return FieldsBlock(
      {
        for (final field in toFields(object)._fields.entries)
          field.key: adapters.encode(field.value),
      },
    );
  }
}

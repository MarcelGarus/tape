import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:meta/meta.dart';

import 'utils.dart';

/// A concrete class that has been annotated with `@TapeType()` and that wants
/// a generated adapter.
class ConcreteTapeType {
  ConcreteTapeType({@required this.name, @required this.fields})
      : assert(name != null),
        assert(fields != null);

  final String name;
  final List<ConcreteTapeField> fields;

  factory ConcreteTapeType.fromElement(ClassElement element) {
    return ConcreteTapeType(
      name: element.name,
      fields: [
        for (final field in element.fields.where((field) => field.isTapeField))
          ConcreteTapeField.fromElement(field),
      ],
    );
  }

  factory ConcreteTapeType.fromJson(Map<String, dynamic> data) {
    return ConcreteTapeType(
      name: data['name'],
      fields: (data['fields'] as List<Map<String, dynamic>>)
          .map((fieldData) => ConcreteTapeField.fromJson(fieldData))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'fields': fields.map((field) => field.toJson()).toList(),
    };
  }
}

class ConcreteTapeField {
  ConcreteTapeField({
    @required this.id,
    @required this.type,
    @required this.name,
  })  : assert(id != null),
        assert(type != null),
        assert(name != null);

  final int id;
  final DartType type;
  final String name;

  factory ConcreteTapeField.fromElement(FieldElement element) {
    assert(element.isTapeField);
    var obj = tapeFieldChecker.firstAnnotationOfExact(element);
    var id = obj.getField('id').toIntValue();
    return ConcreteTapeField(
      id: id,
      type: element.type,
      name: element.name,
    );
  }

  factory ConcreteTapeField.fromJson(Map<String, dynamic> data) {
    return ConcreteTapeField(
      id: data['id'],
      type: data['type'], // TODO:
      name: data['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.element.name,
      'name': name,
    };
  }
}

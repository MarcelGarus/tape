import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:meta/meta.dart';

import 'utils.dart';

/// A concrete class that has been annotated with `@TapeType()` and that wants
/// a generated adapter.
class ConcreteTapeClass {
  ConcreteTapeClass({
    @required this.name,
    @required this.trackingCode,
    @required this.fields,
  })  : assert(name != null),
        assert(trackingCode != null),
        assert(fields != null);

  final String name;
  final String trackingCode;
  final List<ConcreteTapeField> fields;

  factory ConcreteTapeClass.fromElement(ClassElement element) {
    return ConcreteTapeClass(
      name: element.name,
      trackingCode: element.trackingCode,
      fields: [
        for (final field in element.fields.where((field) => field.isTapeField))
          ConcreteTapeField.fromElement(field),
      ],
    );
  }

  factory ConcreteTapeClass.fromJson(Map<String, dynamic> data) {
    return ConcreteTapeClass(
      name: data['name'],
      trackingCode: data['tracking_code'],
      fields: (data['fields'] as List<Map<String, dynamic>>)
          .map((fieldData) => ConcreteTapeField.fromJson(fieldData))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'tracking_code': trackingCode,
      'fields': fields.map((field) => field.toJson()).toList(),
    };
  }
}

class ConcreteTapeField {
  ConcreteTapeField({
    @required this.id,
    @required this.type,
    @required this.typeTrackingCode,
    @required this.name,
  })  : assert(id != null),
        assert(type != null),
        assert(name != null);

  final int id;
  final String type;
  final String typeTrackingCode;
  final String name;

  factory ConcreteTapeField.fromElement(FieldElement element) {
    assert(element.isTapeField);

    return ConcreteTapeField(
      id: element.fieldId,
      type: element.type.getDisplayString(),
      typeTrackingCode: (element.type.element?.hasTrackingCode ?? false)
          ? element.type.element.trackingCode
          : element.type.getDisplayString(),
      name: element.name,
    );
  }

  factory ConcreteTapeField.fromJson(Map<String, dynamic> data) {
    return ConcreteTapeField(
      id: data['id'],
      type: data['type'],
      typeTrackingCode: data['type_tracking_code'],
      name: data['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'type_tracking_code': typeTrackingCode,
      'name': name,
    };
  }
}

import 'package:analyzer/dart/element/element.dart';
import 'package:meta/meta.dart';

import 'utils.dart';

// /// Every tape type should have an adapter named `AdapterFor<TypeName>` that is
// /// registered in the `tape.dart` file using `Tape.registerAdapters` or in a
// /// third-party package using `Tape.registerReservedAdapters`.
// class LockedTapeType {
//   LockedTapeType({@required this.id});

//   final int id;
// }

// /// A concrete class that has been annotated with `@TapeType()` and that wants
// /// a generated adapter.
// class ConcreteTapeClass {
//   ConcreteTapeClass({
//     @required this.name,
//     @required this.type,
//     @required this.fields,
//   })  : assert(name != null),
//         assert(fields != null);

//   final String name;
//   final String type;
//   final List<ConcreteTapeField> fields;

//   factory ConcreteTapeClass.fromElement(ClassElement element) {
//     return ConcreteTapeClass(
//       name: element.name,
//       type: element.thisType.getDisplayString(withNullability: false),
//       fields: [
//         for (final field in element.fields.where((field) => field.isTapeField))
//           ConcreteTapeField.fromElement(field),
//       ],
//     );
//   }

//   factory ConcreteTapeClass.fromJson(Map<String, dynamic> data) {
//     return ConcreteTapeClass(
//       name: data['name'],
//       type: data['type'],
//       fields: (data['fields'] as List<Map<String, dynamic>>)
//           .map((fieldData) => ConcreteTapeField.fromJson(fieldData))
//           .toList(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'type': type,
//       'fields': fields.map((field) => field.toJson()).toList(),
//     };
//   }
// }

// class ConcreteTapeField {
//   ConcreteTapeField({
//     @required this.id,
//     @required this.type,
//     @required this.typeTrackingCode,
//     @required this.name,
//   })  : assert(id != null),
//         assert(type != null),
//         assert(name != null);

//   final int id;
//   final String type;
//   final int typeId;
//   final String name;

//   factory ConcreteTapeField.fromElement(FieldElement element) {
//     assert(element.isTapeField);

//     return ConcreteTapeField(
//       id: element.fieldId,
//       type: element.type.getDisplayString(),
//       typeTrackingCode: (element.type.element?.hasTrackingCode ?? false)
//           ? element.type.element.trackingCode
//           : element.type.getDisplayString(),
//       name: element.name,
//     );
//   }

//   factory ConcreteTapeField.fromJson(Map<String, dynamic> data) {
//     return ConcreteTapeField(
//       id: data['id'],
//       type: data['type'],
//       typeTrackingCode: data['type_tracking_code'],
//       name: data['name'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'type': type,
//       'type_tracking_code': typeTrackingCode,
//       'name': name,
//     };
//   }
// }

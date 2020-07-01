import 'package:analyzer/dart/element/element.dart';
// That's just the way the import system works for now.
// ignore: implementation_imports
import 'package:build/src/builder/build_step.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:dartx/dartx.dart';

import 'utils.dart';

@immutable
class TapeGenerator extends Generator {
  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    // final foundClasses = <ConcreteTapeClass>[];
    final adapters = <String>[];

    for (final element in library.allElements) {
      // @TapeClass
      if (element is ClassElement && element.isTapeClass) {
        if (element.isEnum) throw 'Enum is annotated with @TapeClass.';

        // foundClasses.add(ConcreteTapeClass.fromElement(element));
        adapters.add(_generateAdapter(element));
      }
    }

    // for (final foundClass in foundClasses) {
    //   log(JsonEncoder.withIndent('  ').convert(foundClass));
    // }
    return adapters.join('\n');
  }
}

String _generateAdapter(ClassElement element) {
  final code = StringBuffer()
    ..writeln('class AdapterFor${element.nameWithGenerics.withoutCruft} '
        'extends TapeClassAdapter<${element.nameWithGenerics}> {')
    ..writeln(
        '  const AdapterFor${element.nameWithoutGenerics.withoutCruft}();')
    ..writeln()
    ..write(_generateFromFieldsMethod(element))
    ..writeln()
    ..write(_generateToFieldsMethod(element))
    ..writeln('}');

  return code.toString();
}

String _generateFromFieldsMethod(ClassElement element) {
  final code = StringBuffer()
    ..writeln('@override')
    ..writeln('${element.nameWithGenerics} fromFields(Fields fields) {')
    ..writeln('  return ${element.nameWithGenerics}(');

  final constructor = element.constructors.firstWhere(
    (constructor) => constructor.name.isEmpty,
    orElse: () => throw 'Provide an unnamed constructor',
  );

  final fields = element.fieldsToTape;
  // TODO(marcelgarus): ensure that all fields also have a fieldId
  for (final parameter in constructor.initializingFormalParameters) {
    final field =
        fields.firstOrNullWhere((field) => field.name == parameter.name);
    if (field == null) {
      continue;
    }
    fields.remove(field);
    if (parameter.isNamed) {
      code.write('${parameter.name}: ');
    }
    code.writeln('${_generateFieldGetter(field)},');
  }
  code.writeln(')');

  // There may still be fields to initialize that were not in the constructor
  // as initializing formals. We hope these are mutable fields, so we using
  // cascades.
  for (final field in fields) {
    code.write('..${field.name} = ${_generateFieldGetter(field)}');
  }

  code..writeln(';')..writeln('}');

  return code.toString();
}

String _generateFieldGetter(FieldElement field) {
  final code = StringBuffer()
    ..write('fields.get<${field.type.getDisplayString()}>(${field.fieldId}');
  if (field.defaultValue != null) {
    code.write(', orDefault: ${field.defaultValue}');
  }
  code.writeln(')');

  return code.toString();
}

String _generateToFieldsMethod(ClassElement element) {
  final code = StringBuffer()
    ..writeln('@override')
    ..writeln('Fields toFields(${element.nameWithGenerics} object) {')
    ..writeln('  return Fields({');
  for (final field in element.fieldsToTape) {
    code.writeln('${field.fieldId}: object.${field.name},');
  }
  code..writeln('});')..writeln('}');

  return code.toString();
}

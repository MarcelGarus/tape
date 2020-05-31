import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:tape/tape.dart';
import 'package:dartx/dartx.dart';

import 'concrete_data.dart';
import 'utils.dart';

@immutable
class TapeGenerator extends Generator {
  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    // Initialize logging.
    final logSink = File('tape.log').openWrite(mode: FileMode.append);
    void log(String message) => logSink.writeln(message);

    // Load lock file.
    final lockFile = Object();

    final foundClasses = <ConcreteTapeClass>[];
    final adapters = <String>[];

    for (final element in library.allElements) {
      // @TapeClass
      if (element is ClassElement && element.isTapeClass) {
        if (element.isEnum) throw 'Enum is annotated with @TapeClass.';

        foundClasses.add(ConcreteTapeClass.fromElement(element));
        adapters.add(_generateAdapter(element));
      }
    }

    for (final foundClass in foundClasses) {
      log(JsonEncoder.withIndent('  ').convert(foundClass));
    }
    await logSink.close();
    return adapters.join('\n');
  }
}

String _generateAdapter(ClassElement element) {
  final nameWithGenerics =
      element.thisType.getDisplayString(withNullability: false);
  final nameWithoutGenerics = element.name;

  final code = StringBuffer();
  code
    ..writeln(
        'class AdapterFor${nameWithGenerics.withoutCruft} extends TapeClassAdapter<$nameWithGenerics> {')
    ..writeln('  const AdapterFor${nameWithoutGenerics.withoutCruft}();')
    ..writeln();

  // The fromFields method.
  code
    ..writeln('  @override')
    ..writeln('  $nameWithGenerics fromFields(Fields fields) {')
    ..writeln('    return $nameWithGenerics(');

  final constructor = element.constructors.firstWhere(
    (constructor) => constructor.name.isEmpty,
    orElse: () => throw 'Provide an unnamed constructor', // TODO: better error
  );

  final fieldsToTape =
      element.fields.where((field) => field.isTapeField).toList();
  var fields = List<FieldElement>.from(fieldsToTape);
  // TODO: ensure that all fields also have a fieldId
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
    code.writeln(
        'fields.get<${field.type.getDisplayString()}>(${field.fieldId}, orDefault: null),');
  }
  code.writeln(')');

  // There may still be fields to initialize that were not in the constructor
  // as initializing formals. We hope these are mutable fields, so we using
  // cascades.
  for (var field in fields) {
    code.write(
        '..${field.name} = fields.get<${field.type.getDisplayString()}>(${field.fieldId}, orDefault: null)');
  }

  code..writeln(';')..writeln('  }')..writeln('');

  // The toFields method.
  code
    ..writeln('  @override')
    ..writeln('  Fields toFields($nameWithGenerics object) {')
    ..writeln('    return Fields({');
  for (final field in fieldsToTape) {
    code.writeln('${field.fieldId}: object.${field.name},');
  }
  code..writeln('});')..writeln('  }')..writeln('}');

  return code.toString();
}

extension _CruftRemover on String {
  /// Some code generation libraries add some cruft to class names to make a
  /// name collision less likely. This leads to ugly names like `_$Name` though.
  /// So here we remove that cruft.
  String get withoutCruft => replaceAll(RegExp(r'_|\$'), '');
}

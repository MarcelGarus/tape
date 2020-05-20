import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:tape/tape.dart';

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
        'class AdapterFor$nameWithGenerics extends AdapterFor<$nameWithGenerics> {')
    ..writeln('  const AdapterFor$nameWithoutGenerics();')
    ..writeln();

  // The write method.
  code
    ..writeln('  @override')
    ..writeln('  void write(TapeWriter writer, $nameWithGenerics obj) {')
    ..writeln('    writer');

  for (final field in element.fields) {
    code
      ..write('..writeFieldId(${field.fieldId})')
      ..write('..write(obj.${field.name})');
  }
  code..writeln(';')..writeln('  }')..writeln('');

  // The read method.
  code
    ..writeln('  @override')
    ..writeln('  $nameWithGenerics read(TapeReader reader) {')
    ..writeln('    final fields = <int, dynamic>{')
    ..writeln(
        '      for (; reader.hasAvailableBytes;) reader.readFieldId(): reader.read(),')
    ..writeln('    };')
    ..writeln('');

  final constructor = element.constructors.firstWhere(
    (constructor) => constructor.name.isEmpty,
    orElse: () => throw 'Provide an unnamed constructor',
  );

  code.writeln('    return $nameWithoutGenerics(');

  // The remaining fields to initialize.
  var fields = List<FieldElement>.from(element.fields);
  for (final parameter in constructor.initializingFormalParameters) {
    final field = fields.firstWhere((field) => field.name == parameter.name);
    fields.remove(field);
    if (parameter.isNamed) {
      code.write('${parameter.name}: ');
    }
    code.writeln(
        'fields[${field.fieldId}] as ${field.type.getDisplayString()},');
  }
  code.writeln(')');

  // There may still be fields to initialize that were not in the constructor
  // as initializing formals. We hope these are mutable fields, so we using
  // cascades.
  for (var field in fields) {
    code.write(
        '..${field.name} = fields[${field.fieldId}] as ${field.type.getDisplayString()}');
  }

  code..writeln(';')..writeln('  }')..writeln('}');

  return code.toString();
}

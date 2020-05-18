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

    for (final element in library.allElements) {
      // @TapeClass
      if (element is ClassElement && element.isTapeClass) {
        if (element.isEnum) throw 'Enum is annotated with @TapeClass.';
        if (element.isNotTapeType)
          throw 'Class is annotated with @TapeClass, but not @TapeType.';
        if (element.hasNoTrackingCode)
          throw 'Class does not have a tracking code. Consider running `pub run tape`.';

        foundClasses.add(ConcreteTapeClass.fromElement(element));
      }
    }

    for (final foundClass in foundClasses) {
      log(JsonEncoder.withIndent('  ').convert(foundClass));
    }
    await logSink.close();
    return [
      for (final foundClass in foundClasses) ...[
        'class AdapterFor${foundClass.name} extends AdapterFor<${foundClass.name}> {',
        '  const AdapterFor${foundClass.name}();',
        '',
        '  @override',
        '  void write(TapeWriter writer, ${foundClass.name} obj) {',
        [
          '    writer',
          for (final field in foundClass.fields) ...[
            '..writeFieldId(${field.id})',
            '..write(obj.${field.name})',
          ],
          ';',
        ].join(),
        '  }',
        '',
        '  @override',
        '  ${foundClass.name} read(TapeReader reader) {',
        '    final fields = <int, dynamic>{',
        '      for (; reader.hasAvailableBytes;) reader.readFieldId(): reader.read(),',
        '    };',
        '',
        '    return ${foundClass.name}(',
        for (final field in foundClass.fields)
          '      ${field.name}: fields[${field.id}],',
        '    );',
        '  }',
        '}',
      ],
    ].join('\n');
  }
}

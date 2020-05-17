import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:tape/tape.dart';

final _tapeFieldChecker = TypeChecker.fromRuntime(TapeField);

extension on FieldElement {
  bool get isTapeField {
    return _tapeFieldChecker.hasAnnotationOf(this, throwOnUnresolved: false);
  }
}

@immutable
class TapeGenerator extends GeneratorForAnnotation<TapeType> {
  @override
  dynamic generateForAnnotatedElement(Element element,
      ConstantReader annotationReader, BuildStep buildStep) async {
    // Initialize logging.
    final _logSink = File('tape.log').openWrite(mode: FileMode.append);
    void _log(String message) => _logSink.writeln(message);

    // Parse annotation.
    // final annotation = TapeType(
    //   annotationReader.read('nextFieldId').intValue,
    //   annotationReader.read('trackingCode').stringValue,
    // );
    _log('uri=${element.librarySource.uri}');
    // _log('contents=${element.librarySource.contents.data}');
    _log('source=${element.librarySource.source}');

    // Write to the source file.
    final absolutePath =
        element.librarySource.source.fullName; // /example/lib/main.dart
    final pathFromRoot = absolutePath.substring(1); // example/lib/main.dart
    final pathFromProject =
        pathFromRoot.substring(pathFromRoot.indexOf('/') + 1); // lib/main.dart
    final sourceFile = File(pathFromProject).openWrite(mode: FileMode.append);
    sourceFile
        .writeln('// Hello from the code generator (from a dynamic path).');
    await sourceFile.close();
    final source = await File(pathFromProject).readAsString();
    await File(pathFromProject).writeAsString(
        source.replaceAll('@TapeAll', '@TapeType(0, \'abcdef123\')'));
    _log('location_components=${element.location.components}');
    _log('location_encoding=${element.location.encoding}');
    _log('location_type=${element.location.runtimeType}');

    if (element is! ClassElement) {
      _log('This is not a class: $element');
      throw InvalidGenerationSourceError(
          'Only annotate classes with @TapeType()');
    }

    final classElement = element as ClassElement;
    final classToTape = _parseClass(classElement);
    _log(json.encode(classToTape));

    await _logSink.close();
    return '/*Some generated code.*/';
  }

  static ConcreteTapeType _parseClass(ClassElement element) {
    return ConcreteTapeType(
      name: element.name,
      fields: [
        for (final field in element.fields.where((field) => field.isTapeField))
          _parseField(field),
      ],
    );
  }

  static ConcreteTapeField _parseField(FieldElement element) {
    assert(element.isTapeField);
    var obj = _tapeFieldChecker.firstAnnotationOfExact(element);
    var id = obj.getField('id').toIntValue();
    return ConcreteTapeField(
      id: id,
      type: element.type,
      name: element.name,
    );
  }
}

/// A concrete class that has been annotated with `@TapeType()` and that wants
/// a generated adapter.
class ConcreteTapeType {
  ConcreteTapeType({@required this.name, @required this.fields})
      : assert(name != null),
        assert(fields != null);

  final String name;
  final List<ConcreteTapeField> fields;

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.element.name,
      'name': name,
    };
  }
}

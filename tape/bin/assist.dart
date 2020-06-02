import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:meta/meta.dart';
import 'package:watcher/watcher.dart';
import 'package:dartx/dartx.dart';
import 'package:dartx/dartx_io.dart';

import 'code_replacement.dart';
import 'assist_utils.dart';
import 'tape.dart';
import 'console.dart';

/// Assists the developer by autocompleting annotations.
final assist = Command(
  names: ['assist'],
  description: 'assists you while writing code',
  action: _assist,
);

Future<int> _assist(List<String> args) async {
  print('Running assist...');
  await assistWithFile('lib/main.dart');

  Watcher('.').events.listen((event) async {
    if (event.type == ChangeType.ADD || event.type == ChangeType.MODIFY) {
      await assistWithFile(event.path);
    }
  });

  return 0;
}

Future<void> assistWithFile(String path) async {
  final task = Task('Assisting with file $path...');

  // Check it's a file we're interested in.
  if (!path.endsWith('.dart')) {
    task.success("Ignored $path, since it's not a Dart file.");
    return;
  }
  // TODO: Maybe support more general generated files here?
  if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
    task.success("Ignored $path, since it's a generated file.");
    return;
  }

  // Read the source from the file.
  final file = File(path);
  String oldSource;
  task.message = 'Reading $path...';
  try {
    oldSource = await file.readAsString();
  } catch (e) {
    task.error("Couldn't read from $path.");
    return;
  }

  // Enhance it.
  String newSource;
  task.message = 'Enhancing the code of $path...';
  try {
    newSource = _enhanceSourceCode(
      fileName: file.name,
      sourceCode: oldSource,
    );
  } on SourceCodeHasErrorsException {
    task.warning('Ignored $path, since it contained syntax errors.');
    return;
  } catch (e, st) {
    task.error(
        'An internal error occurred while enhancing $path. Please file an issue:');
    // TODO: print error in red
    print(e);
    print(st);
    return;
  }

  if (oldSource.length == newSource.length) {
    task.success("$path already looks great.");
    return;
  }

  task.message = 'Formatting the new code for $path...';
  try {
    newSource = DartFormatter().format(newSource);
  } on FormatterException {
    task.error(
        "An error occurred while formatting the new code for $path. This shouldn't happen.");
    return;
  }

  task.message = 'Saving the new code for $path...';
  try {
    await File(path).writeAsString(newSource);
  } catch (e) {
    task.error("Couldn't write to $path.");
  }

  task.success('Assisted with $path.');
}

class SourceCodeHasErrorsException implements Exception {}

String _enhanceSourceCode({
  @required String fileName,
  @required String sourceCode,
}) {
  // Parse the source code.
  CompilationUnit compilationUnit;
  try {
    compilationUnit = parseString(content: sourceCode).unit;
  } on ArgumentError {
    throw SourceCodeHasErrorsException();
  }

  // These will be replacements for certain parts of the file. For example, an
  // unfinished `@TapeClass` may get replaced with `@TapeClass(nextFieldId: 10)`
  // or the space before a field inside a @TapeClass that is not annotated yet
  // will get replaced by `@TapeField(10, orDefault: ...)\n`.
  var replacements = <Replacement>[];

  var containsTapeAnnotations = false;
  final classDeclarations =
      compilationUnit?.declarations?.whereType<ClassDeclaration>() ??
          <ClassDeclaration>[];

  for (final declaration in classDeclarations.where((c) => c.isTapeClass)) {
    containsTapeAnnotations = true;
    final fields = declaration.members.whereType<FieldDeclaration>();
    var nextFieldId = declaration.tapeClassAnnotation.nextFieldId ??
        fields.map((field) => (field.fieldId ?? -1) + 1).max() ??
        0;

    for (final field in fields) {
      if (!field.isTapeField && !field.doNotTape) {
        // This field has no annotation although it is inside a @TapeClass.
        // Add a @TapeField annotation.
        replacements.add(Replacement(
          offset: field.offset,
          length: 0,
          replaceWith: '\n\n@TapeField($nextFieldId, defaultValue: TODO)\n',
        ));
        nextFieldId++;
      } else if (field.isTapeField && field.fieldId == null) {
        // Finish the @TapeField annotation.
        replacements.add(Replacement.forNode(
          field.tapeFieldAnnotation,
          '\n\n@TapeField($nextFieldId, defaultValue: TODO)',
        ));
        nextFieldId++;
      }
    }

    if (declaration.nextFieldId == null) {
      // Finish the @TapeClass annotation.
      replacements.add(Replacement.forNode(
        declaration.tapeClassAnnotation,
        '@TapeClass(nextFieldId: $nextFieldId)',
      ));
    }
  }

  if (containsTapeAnnotations) {
    assert(fileName.endsWith('.dart'));
    final extensionlessFileName =
        fileName.substring(0, fileName.length - '.dart'.length);
    final generatedFileName = '$extensionlessFileName.g.dart';

    // Make sure a `part 'some_file.g.dart';` directive exists.
    final hasDirective = compilationUnit.directives
        .whereType<PartDirective>()
        .any((part) => part.uri.stringValue == generatedFileName);
    if (!hasDirective) {
      final offset = compilationUnit.declarations.first.offset;

      replacements.add(Replacement(
        offset: offset,
        length: 0,
        replaceWith: "part '$generatedFileName';\n\n",
      ));
    }
  }

  return sourceCode.apply(replacements);
}

import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:meta/meta.dart';
import 'package:watcher/watcher.dart';
import 'package:dartx/dartx.dart';
import 'package:dartx/dartx_io.dart';

import 'code_replacement.dart';
import 'ast_utils.dart';
import 'tape.dart';
import 'console.dart';
import 'utils.dart';

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
  final file = File(path);

  // Check it's a file we're interested in.
  if (file.extension != '.dart') {
    task.success("Ignored $path, since it's not a Dart file.");
    return;
  }
  // TODO: Maybe support more generated files here?
  if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
    task.success("Ignored $path, since it's a generated file.");
    return;
  }

  assistWithDartFile(task, file);
}

void assistWithDartFile(Task task, File file) {
  final path = file.path;
  task.modifyFile(
    file: file,
    onFileNotFound: "Can't find file $path",
    onCannotReadFromFile: "Can't read from $path.",
    onFileContainsSyntaxErrors: "File $path contains syntax errors.",
    onNothingModified: "$path already looks great.",
    onCannotFormatModifiedCode: "An error occurred while formatting the new "
        "code for $path. This shouldn't happen.",
    onCannotWriteToFile: "Couldn't write updated code to $path.",
    onDone: 'Assisted with $path.',
    modify: (unit) async* {
      var containsTapeAnnotations = false;
      final classDeclarations =
          unit?.declarations?.whereType<ClassDeclaration>() ?? [];

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
            yield Replacement(
              offset: field.offset,
              length: 0,
              replaceWith: '\n\n@TapeField($nextFieldId, defaultValue: TODO)\n',
            );
            nextFieldId++;
          } else if (field.isTapeField && field.fieldId == null) {
            // Finish the @TapeField annotation.
            yield Replacement.forNode(
              field.tapeFieldAnnotation,
              '\n\n@TapeField($nextFieldId, defaultValue: TODO)',
            );
            nextFieldId++;
          }
        }

        if (declaration.nextFieldId == null) {
          // Finish the @TapeClass annotation.
          yield Replacement.forNode(
            declaration.tapeClassAnnotation,
            '@TapeClass(nextFieldId: $nextFieldId)',
          );
        }
      }

      if (containsTapeAnnotations) {
        final fileName = file.name;
        assert(fileName.endsWith('.dart'));
        final extensionlessFileName =
            fileName.substring(0, fileName.length - '.dart'.length);
        final generatedFileName = '$extensionlessFileName.g.dart';

        // Make sure a `part 'some_file.g.dart';` directive exists.
        final hasDirective = unit.directives
            .whereType<PartDirective>()
            .any((part) => part.uri.stringValue == generatedFileName);
        if (!hasDirective) {
          final offset = unit.declarations.first.offset;

          yield Replacement(
            offset: offset,
            length: 0,
            replaceWith: "part '$generatedFileName';\n\n",
          );
        }
      }
    },
  );
}

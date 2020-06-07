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
import 'tapegen.dart';
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
  await for (final file in Directory('lib').list(recursive: true)) {
    await assistWithFile(file.path);
  }

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
      final classes = unit?.declarations?.whereType<ClassDeclaration>() ?? [];

      for (final declaration in classes.where((cls) => cls.isTapeClass)) {
        containsTapeAnnotations = true;
        yield* autocompleteAnnotations(
          declaration,
          declaration.members.whereType<FieldDeclaration>().toList(),
        );
      }

      for (final declaration in classes.where((cls) => cls.isFreezed)) {
        final freezedTapeFactories = declaration.members
            .whereType<ConstructorDeclaration>()
            .where((constructor) => constructor.factoryKeyword != null)
            .where((c) => c.isTapeClass);
        for (final constructor in freezedTapeFactories) {
          yield* autocompleteAnnotations(
            constructor,
            constructor.parameters.parameters,
            insertNewlineBeforeNewFieldAnnotations: false,
          );
        }
      }

      if (containsTapeAnnotations) {
        yield* ensurePartOfDirectiveExists(unit, file);
        // TODO: ensure `import 'package:tape/tape.dart';` directive exists
      }
    },
  );
}

/// Annotates a structure annotated with `@TapeClass`.
Stream<Replacement> autocompleteAnnotations(
  AstNode parentStructure,
  List<AstNode> fields, {
  bool insertNewlineBeforeNewFieldAnnotations = true,
}) async* {
  /// A quick rundown of how this will work:
  /// - First, we find the [nextFieldId].
  /// - Then, we iterate over the fields and add annotations and/or field ids
  ///   where necessary. Everytime we need to insert a field id, we use
  ///   [nextFieldId] and then increase it by one.
  /// - After we annotated all the fields, we update the `@TapeClass` annotation
  ///   to contain the new, correct [nextFieldId].

  final tapeClassAnnotation = parentStructure.tapeClassAnnotation;
  assert(tapeClassAnnotation != null);

  /// Determine the next field id as
  /// - The `nextFieldId` parameter of the `@TapeClass` annotation.
  /// - If it doesn't have one, as the maximum field id of fields + 1.
  /// - If there are no `@TapeField`s with field ids, then default to 0.
  var nextFieldId = tapeClassAnnotation.nextFieldId;
  nextFieldId ??= fields
      .map((field) {
        final fieldId = field.tapeFieldAnnotation?.fieldId;
        return fieldId == null ? null : (fieldId + 1);
      })
      .whereNotNull()
      .max();
  nextFieldId ??= 0;

  for (final field in fields.where((field) => !field.doNotTape)) {
    if (!field.isTapeField) {
      /// This field has no annotation although it is inside a `@TapeClass`.
      /// Add a `@TapeField` annotation.
      final prefix = insertNewlineBeforeNewFieldAnnotations ? '\n\n' : '';
      yield Replacement.insert(
        offset: field.offset,
        replaceWith: '$prefix@TapeField($nextFieldId, defaultValue: TODO)\n',
      );
      nextFieldId++;
      continue;
    }

    /// This field is already annotated with a `@TapeField` annotation. Maybe it
    /// doesn't contain a field id or default value yet. If so, we finish the
    /// annotation.
    final annotation = field.tapeFieldAnnotation;
    final fieldId = annotation.fieldId;
    var defaultValue = annotation.defaultValue ??
        field.freezedDefaultAnnotation.freezedDefaultValue ??
        'TODO'; // Purposely creates an error in the file.

    if (fieldId == null) {
      yield Replacement.forNode(
        field.tapeFieldAnnotation,
        '@TapeField($nextFieldId, defaultValue: $defaultValue)',
      );
      nextFieldId++;
    } else {
      yield Replacement.forNode(
        field.tapeFieldAnnotation,
        '@TapeField($fieldId, defaultValue: $defaultValue)',
      );
    }
  }

  /// Update the `@TapeClass` annotation.
  if (tapeClassAnnotation.nextFieldId == null) {
    /// It doesn't contain a `nextFieldId` field yet.
    /// Finish the @TapeClass annotation.
    yield Replacement.forNode(
      tapeClassAnnotation,
      '@TapeClass(nextFieldId: $nextFieldId)',
    );
  }
}

Stream<Replacement> ensurePartOfDirectiveExists(
  CompilationUnit unit,
  File file,
) async* {
  final generatedFileName = '${file.nameWithoutExtension}.g.dart';

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

import 'dart:io';
import 'dart:math';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:build_config/build_config.dart';
import 'package:meta/meta.dart';
import 'package:watcher/watcher.dart';
import 'package:dartx/dartx.dart';

import 'utils.dart';

void main(List<String> args) async {
  await _updateFile('lib/main.dart');

  Watcher('.').events.listen((event) {
    if (event.type == ChangeType.ADD || event.type == ChangeType.MODIFY) {
      _updateFile(event.path);
    }
  });
}

class Replacement {
  Replacement({
    @required this.offset,
    @required this.length,
    @required this.replaceWith,
  });
  Replacement.forNode(AstNode node, this.replaceWith)
      : offset = node.offset,
        length = node.length;

  final int offset;
  final int length;
  final String replaceWith;
}

Future<void> _updateFile(String path) async {
  print('Updating $path…');

  // Read the source from the file and parse it into an AST.
  final oldSource = await File(path).readAsString();
  final compilationUnit = parseString(content: oldSource).unit;

  // These will be replacements for certain parts of the file. For example, an
  // unfinished `@TapeClass` may get replaced with `@TapeClass(nextFieldId: 10)`
  // or the space before a field inside a @TapeClass that is not annotated yet
  // will get replaced by `@TapeField(10)\n`.
  var replacements = <Replacement>[];

  var containsTapeAnnotations = false;
  final classDeclarations =
      compilationUnit?.declarations?.whereType<ClassDeclaration>() ??
          <ClassDeclaration>[];

  for (final declaration in classDeclarations.where((c) => c.isTapeClass)) {
    containsTapeAnnotations = true;
    final fields = declaration.members.whereType<FieldDeclaration>();
    var maxFieldId = fields.map((field) => field.fieldId ?? -1).max() ?? -1;

    for (final field in fields) {
      if (!field.isTapeField && !field.doNotTape) {
        // This field has no annotation although it is inside a @TapeClass.
        // Add a @TapeField annotation.
        final fieldId = ++maxFieldId;
        replacements.add(Replacement(
          offset: field.offset,
          length: 0,
          replaceWith: '@TapeField($fieldId)\n',
        ));
      } else if (field.isTapeField && field.fieldId == null) {
        // Finish the @TapeField annotation.
        final fieldId = ++maxFieldId;
        replacements.add(Replacement.forNode(
          field.tapeFieldAnnotation,
          '@TapeField($fieldId)',
        ));
      }
    }

    if (declaration.nextFieldId == null) {
      // Finish the @TapeClass annotation.
      replacements.add(Replacement.forNode(
        declaration.tapeClassAnnotation,
        '@TapeClass(nextFieldId: ${maxFieldId + 1})',
      ));
    }
  }

  if (containsTapeAnnotations) {
    // Make sure a `part 'some_file.g.dart';` directive exists.
    final hasDirective = compilationUnit.directives
        .whereType<PartDirective>()
        .any((part) => part.uri.stringValue.endsWith('.g.dart'));
    if (!hasDirective) {
      final offset = compilationUnit.declarations.first.offset;
      final fileName = path.substring(path.lastIndexOf('/') + 1);
      final extensionlessFileName =
          fileName.substring(0, path.lastIndexOf('.'));
      // replacements.add(Replacement(
      //   offset: offset,
      //   length: 0,
      //   replaceWith: "part '$extensionlessFileName.g.dart';\n\n",
      // ));
    }
  }
  print('Replacements: $replacements');

  // We now got a list of replacements. The order in which we apply them is
  // important so that we don't mess up the offsets.
  replacements = replacements.sortedBy((replacement) => replacement.offset);
  var cursor = 0;
  var buffer = StringBuffer();
  for (final replacement in replacements) {
    buffer.write(oldSource.substring(cursor, replacement.offset));
    buffer.write(replacement.replaceWith);
    cursor = replacement.offset + replacement.length;
  }
  buffer.write(oldSource.substring(cursor));
  final newSource = buffer.toString();

  if (oldSource.length != newSource.length) {
    await File(path).writeAsString(newSource);
    print('Filling out trackingCodes for $path');
  }
}

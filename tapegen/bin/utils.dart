import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:dart_style/dart_style.dart';
import 'package:meta/meta.dart';

import 'code_replacement.dart';
import 'console.dart';

const tapeFilePath = 'lib/tape.dart';
const mainFilePath = 'lib/main.dart';

final tapeFile = File(tapeFilePath);
final mainFile = File(mainFilePath);

extension FileParser on Task {
  Future<void> modifyFile({
    @required File file,
    @required String onFileNotFound,
    @required String onCannotReadFromFile,
    @required String onFileContainsSyntaxErrors,
    @required String onNothingModified,
    @required String onCannotFormatModifiedCode,
    @required String onCannotWriteToFile,
    @required String onDone,
    @required Stream<Replacement> Function(CompilationUnit unit) modify,
  }) async {
    if (!file.existsSync()) {
      error(onFileNotFound);
      return;
    }

    updateSubtask('reading');
    String code;
    try {
      code = await file.readAsString();
    } catch (e) {
      error(onCannotReadFromFile);
      return;
    }

    updateSubtask('parsing');
    CompilationUnit compilationUnit;
    try {
      compilationUnit = parseString(content: code).unit;
    } on ArgumentError {
      error(onFileContainsSyntaxErrors);
      return;
    }

    updateSubtask('modifying code');
    final replacements = await modify(compilationUnit).toList();
    String newCode = code.applyAll(replacements);

    if (code.length == newCode.length) {
      success(onNothingModified);
      return;
    }

    updateSubtask('formatting new code');
    try {
      newCode = DartFormatter().format(newCode);
    } on FormatterException {
      error(onCannotFormatModifiedCode);
      return;
    }

    updateSubtask('saving new code');
    try {
      await file.writeAsString(newCode);
    } catch (e) {
      error(onCannotWriteToFile);
      return;
    }

    success(onDone);
  }
}

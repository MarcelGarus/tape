import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:dartx/dartx.dart';

import 'assist.dart';
import 'code_replacement.dart';
import 'console.dart';

const _path = 'lib/tape.dart';

Future<Map<int, dynamic>> getRegisteredAdapters() async {
  final task = Task('Parsing tapefile...');

  // Read the source from the file.
  final file = File(_path);
  String sourceCode;
  task.update('Reading tapefile...');
  try {
    sourceCode = await file.readAsString();
  } catch (e) {
    task.error("Couldn't read from $_path.");
    return null;
  }

  // Parse the source code.
  CompilationUnit compilationUnit;
  try {
    compilationUnit = parseString(content: sourceCode).unit;
  } on ArgumentError {
    task.error("Couldn't parse $_path, because it contains syntax errors.");
    return null;
  }

  task.success('Done.');

  final adapterRegistrations = compilationUnit.declarations
      ?.whereType<FunctionDeclaration>()
      ?.where((function) => function.name.toSource() == 'initializeTape')
      ?.map((function) => function.functionExpression.body)
      ?.whereType<BlockFunctionBody>()
      ?.map((body) => body.block.statements)
      ?.flatten()
      ?.whereType<ExpressionStatement>()
      ?.map((statement) => statement.expression)
      ?.whereType<MethodInvocation>()
      ?.where((invocation) =>
          invocation.methodName.toSource() == 'registerAdapters')
      // TODO: use singleOrNull when it is released
      ?.map((invocation) => invocation.argumentList.arguments
          .singleWhere((_) => true, orElse: () => null))
      ?.whereType<SetOrMapLiteral>()
      ?.map((map) => map.elements)
      ?.flatten()
      ?.whereType<MapLiteralEntry>(); // TODO: support spread operator

  for (final registration in adapterRegistrations) {
    print('Registering adapter ${registration.value} under id '
        '${registration.key}');
  }
}

T _debugPrint<T>(T val) {
  print(val);
  return val;
}

import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:dartx/dartx.dart';

import 'code_replacement.dart';
import 'console.dart';
import 'tapegen.dart';
import 'utils.dart';

/// Helps the developerw integrate tape into their app.
final init = Command(
  names: ['init', 'i'],
  description: 'create tape boilerplate for your project',
  action: _init,
);

Future<int> _init(List<String> args) async {
  await createTapeFile();
  await callInitializeTapeFromMain();
  // TODO: add build_runner and tapegen dev_dependencies

  // final adapters = getRegisteredAdapters();

  return 0;
}

Future<void> createTapeFile() async {
  final task = Task('Creating $tapeFilePath...');
  final file = File('lib/tape.dart');
  if (file.existsSync()) {
    task.success('Tape file already exists at $tapeFilePath.');
    return;
  }

  try {
    await File('lib/tape.dart').writeAsString(
      [
        "import 'package:tape/tape.dart';",
        "",
        "void initializeTape() {",
        "  // 📦 Register adapters from taped-packages.",
        "  //Tape",
        "  //  ..initializeFlutter()",
        "  //  ..initializeTimeTable()",
        "  //  ..initializeRrule();",
        "",
        "  Tape.registerAdapters({",
        "    // 🌱 For now, it's pretty empty here.",
        "    // Adapters for your types will be registered here.",
        "  });",
        "}",
        "",
      ].join('\n'),
      flush: true,
    );
  } catch (e) {
    task.error("Couldn't create tape file at $tapeFilePath.");
    return;
  }
  task.success('Created tape file at $tapeFilePath.');
}

Future<void> callInitializeTapeFromMain() async {
  final task = Task('Calling initializeTape() from $mainFilePath');
  String errorString(String reason) => "Can't automatically call "
      "initializeTape() in your main method because $reason. You'll have to "
      "manually insert the call to initializeTape() at the beginning of the "
      "main method.";

  task.modifyFile(
    file: mainFile,
    onFileNotFound: errorString("$mainFilePath doesn't exist"),
    onCannotReadFromFile: errorString("we couldn't read from $mainFilePath"),
    onFileContainsSyntaxErrors:
        errorString("$mainFilePath contains syntax errors"),
    onNothingModified: "You already call initializeTape() in your main method "
        "in $mainFilePath.",
    onCannotFormatModifiedCode:
        errorString("the formatting of the newly generated code failed"),
    onCannotWriteToFile: errorString("we couldn't write to $mainFilePath"),
    onDone: "Now calling initializeTape() from $mainFilePath.",
    modify: (unit) async* {
      // TODO: Also recognize absolute imports, like `import 'package:example/tape.dart';`
      // TODO: Even this check is not working yet.
      // Check if the source code already imports the `tape.dart` file.
      final importsTapeFile = unit.directives
          .whereType<ImportDirective>()
          .where((import) => import.selectedUriContent == 'tape.dart')
          .isNotEmpty;
      if (!importsTapeFile) {
        // Add the import directive.
        yield Replacement.insert(
          offset:
              unit.directives.whereType<ImportDirective>().lastOrNull?.end ?? 0,
          replaceWith: "import 'tape.dart';",
        );
      }

      // TODO: Check if the call to initializeTape() is already made.

      // Insert `initializeTape();` at the beginning of the main method.
      final mainFunctionBody = unit.declarations
          ?.whereType<FunctionDeclaration>()
          ?.where((function) => function.name.toSource() == 'main')
          ?.map((function) => function.functionExpression.body)
          ?.singleWhere((_) => true, orElse: () => null);

      if (mainFunctionBody is BlockFunctionBody) {
        // The main method has the form `void main() { some stuff }`. Insert the
        // call directly after the opening brace.
        mainFunctionBody.block.leftBracket.end;
        yield Replacement.insert(
          offset: mainFunctionBody.block.leftBracket.end,
          replaceWith: 'initializeTape();',
        );
      } else if (mainFunctionBody is ExpressionFunctionBody) {
        // The main method has the form `void main() => something;`. Convert it into
        // a block function body.
        yield Replacement.forNode(
          mainFunctionBody,
          '{'
          'initializeTape();'
          '${mainFunctionBody.expression.toSource()};'
          '}',
        );
      } else if (mainFunctionBody is EmptyFunctionBody) {
        // TODO: Throw
        // The main method has the form `void main();`. Main methods can't be
        // abstract, so the user did something weird. We just fail.
        // task.error("Failed to automatically insert a call to initializeTape() "
        //     "because your main method doesn't have a body. $tellUserToDoItThemselves");
      } else {
        throw 'Invalid function body type ${mainFunctionBody.runtimeType}';
      }
    },
  );
}

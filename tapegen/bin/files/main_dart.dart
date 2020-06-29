import '../ast_utils.dart';
import '../console.dart';
import '../errors.dart';
import '../utils.dart';

final mainDartFile = File('lib/main.dart');

extension MainDartFile on File {
  Future<void> addCallToInitializeTape() async {
    assert(this == mainDartFile);

    final task = Task(
      descriptionPresent: 'Adding call to initializeTape() in $path',
      descriptionPast: 'Added call to initializeTape() in $path',
    );
    try {
      var content = await mainDartFile.read();
      content = content.modify(() sync* {
        final unit = content.compile();
        yield* _addDependencyToTapeDartFile(unit);
        yield* _addCallInMainMethod(unit);
      }, onNothingModified: () {
        task.success('You already call initializeTape() in your main method '
            'in $path.');
      });
      mainDartFile.write(content);
      task.success();
    } on CliError catch (e) {
      task.error("$e. You'll have to manually insert the call to "
          'initializeTape() at the beginning of the main method.');
    }
  }

  Iterable<Replacement> _addDependencyToTapeDartFile(
    CompilationUnit unit,
  ) sync* {
    // TODO: Also recognize absolute imports, like `import 'package:example/tape.dart';`
    // TODO: Even this check is not working yet.
    // Check if the source code already imports the `tape.dart` file.
    final importsTapeFile = unit.imports
        .where((import) => import.selectedUriContent == 'tape.dart')
        .isNotEmpty;
    if (!importsTapeFile) {
      // Add the import directive.
      yield Replacement.insert(
        offset: unit.imports.lastOrNull?.end ?? 0,
        replaceWith: "import 'tape.dart';",
      );
    }
  }

  Iterable<Replacement> _addCallInMainMethod(CompilationUnit unit) sync* {
    // TODO: Check if the call to initializeTape() is already made.

    // Insert `initializeTape();` at the beginning of the main method.
    final mainFunctionBody = unit.topLevelFunctions.mainFunction?.body;
    if (mainFunctionBody != null) {
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
    }
  }
}

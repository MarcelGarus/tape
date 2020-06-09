import '../ast_utils.dart';
import '../console.dart';
import '../utils.dart';

final tapeDartFile = File('lib/tape.dart');

class AdapterToRegister {
  AdapterToRegister(this.name) : assert(name != null);

  final String name;
}

extension TapeDartFile on File {
  Future<void> createAndInitialize() async {
    assert(this == tapeDartFile);
    final task = Task(
      descriptionPresent: 'Creating $simplePath...',
      descriptionPast: 'Created $simplePath.',
    );
    if (existsSync()) {
      task.success('Tape file already exists at $simplePath.');
      return;
    }

    try {
      await writeAsString(
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
      task.error("Couldn't create tape file at $path.");
      return;
    }
    task.success('Created tape file at $path.');
  }

  Future<Map<int, dynamic>> getRegisteredAdapters() async {
    final sourceCode = await tapeDartFile.read();
    final unit = sourceCode.compile();

    final adapterRegistrations = unit.topLevelFunctions
        .withName('initializeTape')
        ?.bodyBlock
        ?.statements
        ?.allExpressions
        ?.whereType<MethodInvocation>()
        ?.withName('registerAdapters')
        ?.map((invocation) => invocation.argumentList.arguments.singleOrNull)
        ?.whereType<SetOrMapLiteral>()
        ?.map((map) => map.elements)
        ?.flatten()
        ?.whereType<MapLiteralEntry>(); // TODO: support spread operator

    for (final registration in adapterRegistrations) {
      print('Registering adapter ${registration.value} under id '
          '${registration.key}');
    }
  }

  void registerAdapters(List<AdapterToRegister> adapter) {}
}

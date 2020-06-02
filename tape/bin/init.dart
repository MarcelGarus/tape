import 'dart:io';

import 'tape.dart';
import 'console.dart';

/// Helps the developerw integrate tape into their app.
final init = Command(
  names: ['init', 'i'],
  description: 'create tape boilerplate for your project',
  action: _init,
);

Future<int> _init(List<String> args) async {
  await createTapeFile();
  // TODO: Call initializeTape() from main.dart
  // TODO: add build_runner and tapegen dev_dependencies

  return 0;
}

const tapeFilePath = 'lib/tape.dart';

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

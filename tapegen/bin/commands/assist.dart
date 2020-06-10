import 'dart:io';

import 'package:path/path.dart';
import 'package:watcher/watcher.dart';

import '../console.dart';
import '../files/any_dart.dart';
import '../files/tape_dart.dart';
import '../utils.dart';
import '../tapegen.dart';

/// Assists the developer by autocompleting annotations.
final assist = Command(
  names: ['assist'],
  description: 'assists you while writing code',
  action: (List<String> args) async {
    print('Running assist...');
    await for (final file in Directory('lib').list(recursive: true)) {
      await _assistWithFile(file.path);
    }

    Watcher('.').events.listen((event) async {
      if (event.type == ChangeType.ADD || event.type == ChangeType.MODIFY) {
        await _assistWithFile(event.path);
      }
    });

    return 0;
  },
);

Future<void> _assistWithFile(String path) async {
  final task = Task(
    descriptionPresent: 'Assisting with file $path',
    descriptionPast: 'Assisted with file $path',
  );
  final file = File(path);

  // Check it's a file we're interested in.
  if (file.extension != '.dart') {
    task.success("Ignored $path, since it's not a Dart file.");
    return;
  }
  if ('.'.allMatches(basename(path)).length > 1) {
    task.success("Ignored $path, since it's a generated file.");
    return;
  } else {
    task.subtask('actually assisting');
  }

  final result = await task.run(() => file.assist(task));
  if (result == null) return;

  if (result.tapeTypes.isNotEmpty) {
    final adapters = result.tapeTypes
        .where((type) => !type.contains('<'))
        .map((type) => AdapterToRegister('AdapterFor$type'))
        .toList();
    tapeDartFile.registerAdapters(adapters);
  }
}

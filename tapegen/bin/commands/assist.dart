import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:meta/meta.dart';
import 'package:watcher/watcher.dart';
import 'package:dartx/dartx.dart';
import 'package:dartx/dartx_io.dart';

import '../ast_utils.dart';
import '../console.dart';
import '../files/any_dart.dart';
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
  if (path.allMatches('.').length > 1) {
    task.success("Ignored $path, since it's a generated file.");
    return;
  } else {
    task.subtask('actually assisting');
  }

  final result = await task.run(() => file.assist(task));
  if (result == null) return;

  if (result.tapeTypes.isNotEmpty) {
    // TODO: register adapters
    print(result.tapeTypes);
  }
}

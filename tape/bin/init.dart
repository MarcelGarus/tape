import 'dart:io';

import 'package:args/args.dart';

import 'tape.dart';

/// Helps the developer integrate tape into their app by adding a `tape.dart`
/// file in the `lib` folder and by calling the `initialize` method in the
/// `main.dart` file.
final init = Command(
  names: ['init', 'i'],
  description: 'create tape boilerplate for your project',
  action: _init,
);

Future<int> _init(List<String> args) async {
  print('Running init...');
  // TODO: ensure we're in the project root

  await File('lib/tape.dart').writeAsString('''
import 'package:tape/tape.dart';

void initialize() {
  // 📦 Register adapters from taped-packages.
  Tape
    ..initializeFlutter()
    ..initializeTimeTable()
    ..initializeRrule();

  Tape.registerAdapters({
    // 🌱 For now, it's pretty empty here.
    // Adapters for your types will be registered here.
  });
}
''');

  return 0;
}

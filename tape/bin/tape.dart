import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:meta/meta.dart';

import 'assist.dart';
import 'doctor.dart';
import 'help.dart';
import 'init.dart';
import 'errors.dart';
import 'console.dart';

// Maybe useful emojis: 🧼, 🔭, 🌱, 💉, 🧱, 🕸️

/// $> pub run tape assist
/// Updating lib/main.dart
/// Waiting for new changes...
///
/// $> pub run tape init
/// Creating tape.dart...
/// Adding call to initializeTape in main.dart…
///
/// $> pub run tape build
/// Building adapters...
///

/// A command under tape, for example init or assist.
class Command {
  Command({
    @required this.names,
    @required this.description,
    @required this.action,
  })  : assert(names != null),
        assert(names.isNotEmpty),
        assert(description != null),
        assert(action != null);

  final List<String> names;
  String get name => names.first; // The primary name.

  final String description;
  final Future<int> Function(List<String> args) action;
}

final commands = <Command>[
  help,
  // version, TODO: implement version
  init,
  assist,
  doctor,
];

/// Whether the use rich output, e.g. ansi colors, emojis and loading spinners.
bool useRichOutput = true;

void main(List<String> args) async {
  try {
    await _dispatch(args);
  } on CliError catch (e) {
    print('Error: ${e.id}: $e');
    exitCode = e.exitCode;
  }
}

Future<void> _dispatch(List<String> args) async {
  final commandName = args.firstOrNull;
  final command =
      commands.firstOrNullWhere((cmd) => cmd.names.contains(commandName));

  // Users may want to opt out of rich output, for example, when piping the
  // output into an other program or using a really old terminal.
  useRichOutput =
      !(args.remove('--simple-output') || args.remove('--no-color'));

  if (command != null) {
    exitCode = await command.action(args);
    return;
  }

  if (args.isEmpty) {
    exitCode = await help.action([]);
    return;
  }

  throw UnknownCommandError(commandName);
}

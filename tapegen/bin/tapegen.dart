import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:meta/meta.dart';

import 'commands/assist.dart';
import 'commands/doctor.dart';
import 'commands/help.dart';
import 'commands/init.dart';
import 'console.dart';
import 'errors.dart';

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
  // TODO(marcelgarus): implement version
  // version
  init,
  assist,
  doctor,
];

Future<void> main(List<String> args) async {
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
    args.removeAt(0); // Remove the command itself.
    exitCode = await command.action(args);
    return;
  }

  if (args.isEmpty) {
    exitCode = await help.action([]);
    return;
  }

  throw UnknownCommandError(commandName);
}

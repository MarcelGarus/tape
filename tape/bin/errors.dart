import 'package:string_similarity/string_similarity.dart';

import 'tape.dart';

class CliError implements Exception {
  CliError(this.exitCode);

  final int exitCode;
  String get id => 'te$exitCode'; // "te" stands for "tape error"
}

class UnknownCommandError extends CliError {
  UnknownCommandError(this.commandName)
      : assert(commandName != null),
        super(2);

  final String commandName;

  String toString() {
    final bestMatch = StringSimilarity.findBestMatch(
      commandName,
      commands.map((cmd) => cmd.name).toList(),
    ).bestMatch.target;

    return "Don't know how to handle the command \"$commandName\".\n"
        'Did you mean $bestMatch?\n'
        'If so, run\n'
        '    pub run tape $bestMatch';
  }
}

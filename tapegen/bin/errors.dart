import 'package:string_similarity/string_similarity.dart';

import 'tapegen.dart';

class CliError implements Exception {
  CliError(this.exitCode);

  final int exitCode;
  String get id => 'tce$exitCode'; // "tce" stands for "tape CLI error"
}

class NoPubspecFoundError extends CliError {
  NoPubspecFoundError() : super(2);

  String toString() {
    return "Couldn't find a pubspec.yaml file. Make sure you're in the root "
        'directory of your project.';
  }
}

class UnknownCommandError extends CliError {
  UnknownCommandError(this.commandName)
      : assert(commandName != null),
        super(3);

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

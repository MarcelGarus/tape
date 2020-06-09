import 'dart:io';

import 'package:string_similarity/string_similarity.dart';

import 'tapegen.dart';
import 'utils.dart';

/// An error in the cli.
/// Every [CliError] should have its own exit code. That means, Dart's system of
/// deep inheritance structures doesn't work well here. Instead, we keep it
/// shallow: All errors simply extend [CliError].
class CliError implements Exception {
  CliError(this.exitCode);

  final int exitCode;
  String get id => 'tce$exitCode'; // "tce" stands for "tape CLI error"
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

class FileNotFoundError extends CliError {
  FileNotFoundError(this.file) : super(3);

  final File file;

  String toString() => "Couldn't find ${file.simplePath}.";
}

class CannotReadFromFileError extends CliError {
  CannotReadFromFileError(this.file) : super(4);

  final File file;

  String toString() => "Couldn't read from ${file.simplePath}.";
}

class CannotWriteToFileError extends CliError {
  CannotWriteToFileError(this.file) : super(5);

  final File file;

  String toString() => "Couldn't write to ${file.simplePath}.";
}

class FileContainsSyntaxErrors extends CliError {
  FileContainsSyntaxErrors() : super(6);

  String toString() => "It contains syntax errors.";
}

class CannotFormatCodeError extends CliError {
  CannotFormatCodeError() : super(7);
}

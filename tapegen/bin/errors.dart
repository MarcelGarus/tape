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

class UnexpectedArgumentError extends CliError {
  UnexpectedArgumentError(this.argument) : super(11);

  final String argument;

  String toString() => 'Unknown argument "$argument".';
}

class FileNotFoundError extends CliError {
  FileNotFoundError(this.file) : super(3);

  final File file;

  String toString() => "Couldn't find ${file.normalizedPath}.";
}

class CannotReadFromFileError extends CliError {
  CannotReadFromFileError(this.file) : super(4);

  final File file;

  String toString() => "Couldn't read from ${file.normalizedPath}.";
}

class CannotWriteToFileError extends CliError {
  CannotWriteToFileError(this.file) : super(5);

  final File file;

  String toString() => "Couldn't write to ${file.normalizedPath}.";
}

class FileContainsSyntaxErrors extends CliError {
  FileContainsSyntaxErrors() : super(6);

  String toString() => "It contains syntax errors.";
}

class CannotFormatCodeError extends CliError {
  CannotFormatCodeError() : super(7);
}

class UsedCollectionIfOrForError extends CliError {
  UsedCollectionIfOrForError() : super(8);
}

class ComplicatedExpressionInMapError extends CliError {
  ComplicatedExpressionInMapError() : super(9);
}

class NoRegistrationMapError extends CliError {
  NoRegistrationMapError() : super(10);
}

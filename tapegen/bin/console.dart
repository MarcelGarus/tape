import 'dart:io';

import 'package:console/console.dart';
import 'package:meta/meta.dart';

import 'errors.dart';
import 'utils.dart';

/// Whether the use rich output, e.g. ansi colors, emojis and loading spinners.
// May be overridden in `tape.dart`.
bool useRichOutput = true;

/// Prints a title in bold text.
void printTitle(String title) {
  Console.setBold(true);
  Console.write(title);
  Console.setBold(false);
  Console.write('\n');
}

Future<bool> confirm(String question) async {
  final input = await readInput('$question (Y/n): ');
  return {'', 'y', 'yes'}.contains(input.toLowerCase());
}

/// A task is a unit of work to be done that can have multiple subtasks and is
/// always displayed as a line with a status that can be updated.
///
/// Here's a possible sequence of how the line might be updated:
/// […] Assisting with lib/main.dart...
/// […] Assisting with lib/main.dart, reading...
/// […] Assisting with lib/main.dart, parsing...
/// […] Assisting with lib/main.dart, enhancing...
/// […] Assisting with lib/main.dart, formatting...
/// [✓] Assisted with lib/main.dart.
/// or
/// [X] Assisting with lib/main.dart failed: Couldn't open file.
class Task {
  Task({@required this.descriptionPresent, @required this.descriptionPast}) {
    _message = '$descriptionPresent...';
    _print();
  }

  final String descriptionPresent;
  final String descriptionPast;

  var _status = TaskStatus.pending;
  set _updateStatus(TaskStatus status) {
    _status = status;
    _print();
  }

  String _message = '';
  void _updateMessage(String message) {
    // Make the text at least as wide as the existing text, so we overwrite all
    // the characters.
    _message = message.padRight(_message.length);
    _print();
  }

  void subtask(String subtask) {
    _updateMessage('${descriptionPresent}, $subtask...');
  }

  void _print() {
    Console.moveToColumn(0);
    _printStatusBadge();
    Console.write(' ');
    Console.write(_message);
  }

  void _printStatusBadge() {
    String symbol;
    Color color;
    switch (_status) {
      case TaskStatus.pending:
        symbol = '…';
        break;
      case TaskStatus.success:
        symbol = '✓';
        color = Color.GREEN;
        break;
      case TaskStatus.warning:
        symbol = '!';
        color = Color.YELLOW;
        break;
      case TaskStatus.error:
        symbol = 'X';
        color = Color.RED;
        break;
    }
    if (color != null) {
      Console.setTextColor(color.id);
    }
    Console.setBold(true);
    Console.write('[$symbol]');
    Console.setBold(false);
    Console.resetTextColor();
  }

  void _finish(TaskStatus status, String message) {
    _status = status;
    _updateMessage(message);
    Console.write('\n');
  }

  void success([String alternateMessage]) =>
      _finish(TaskStatus.success, alternateMessage ?? '$descriptionPast.');
  void warning(String message) =>
      _finish(TaskStatus.warning, '$descriptionPresent failed: $message');
  void error(String reason) =>
      _finish(TaskStatus.error, '$descriptionPresent failed: $reason');

  /// Runs the given [callback] and catches and displays errors.
  Future<T> run<T>(Future<T> Function() callback) async {
    try {
      return await callback();
    } on CliError catch (e) {
      error(e.toString());
      return null;
    }
  }
}

enum TaskStatus {
  pending,
  success,
  warning,
  error,
}

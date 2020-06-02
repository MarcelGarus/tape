import 'dart:io';

import 'package:console/console.dart';

import 'errors.dart';

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

/// A task is a line with a status that can be updated.
///
/// Here's a possible sequence of how the line might be updated:
/// […] Assisting with lib/main.dart...
/// […] Parsing lib/main.dart...
/// […] Enhancing lib/main.dart...
/// […] Formatting enhanced lib/main.dart...
/// [✓] Assisted with lib/main.dart.
class Task {
  Task(this._message) {
    _print();
  }

  var _status = Status.pending;
  set status(Status status) {
    _status = status;
    _print();
  }

  String _message = '';
  set message(String message) {
    // Make the text at least as wide as the existing text, so we overwrite all
    // the characters.
    _message = message.padRight(_message.length);
    _print();
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
      case Status.pending:
        symbol = '…';
        break;
      case Status.success:
        symbol = '✓';
        color = Color.GREEN;
        break;
      case Status.warning:
        symbol = '!';
        color = Color.YELLOW;
        break;
      case Status.error:
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

  void finish([Status status, String message]) {
    _status = status;
    this.message = message;
    Console.write('\n');
  }

  void success([String message]) => finish(Status.success, message);
  void warning([String message]) => finish(Status.warning, message);
  void error([String message]) => finish(Status.error, message);
}

enum Status {
  pending,
  success,
  warning,
  error,
}

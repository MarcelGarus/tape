import 'dart:io';
import 'dart:math';

import 'package:watcher/watcher.dart';

void main(List<String> args) async {
  Watcher('.').events.listen((event) {
    if (event.type == ChangeType.ADD || event.type == ChangeType.MODIFY) {
      _updateFile(event.path);
    }
  });
}

Future<void> _updateFile(String path) async {
  final oldSource = await File(path).readAsString();
  final newSource = FileUpdater(oldSource).process();
  if (oldSource.length != newSource.length) {
    await File(path).writeAsString(newSource);
    print('Filling out trackingCodes for $path');
  }
}

class FileUpdater {
  FileUpdater(this.source);

  final String source;
  var cursor = 0;
  bool get isAtEnd => cursor >= source.length;

  bool matches(RegExp regExp) => regExp.hasMatch(source.substring(cursor));

  String process() {
    var buffer = '';
    while (!isAtEnd) {
      if (matches(RegExp(r'^@TapeType\(\)'))) {
        final trackingCode = RandomStringGenerator().next();
        buffer += "@TapeType('$trackingCode')";
        cursor += '@TapeType()'.length;
      } else {
        buffer += source[cursor++];
      }
    }
    return buffer;
  }
}

class RandomStringGenerator {
  static const charset =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890';
  final random = Random();

  String next() => [
        for (int i = 0; i < 32; i++) charset[random.nextInt(charset.length)],
      ].join();
}

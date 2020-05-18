import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:tape/tape.dart';

import 'concrete_data.dart';
import 'utils.dart';

@immutable
class TapeGenerator extends Generator {
  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    // Initialize logging.
    final logSink = File('tape.log').openWrite(mode: FileMode.append);
    // final outSink = File('tape.out').openWrite(mode: FileMode.writeOnly);
    void log(String message) => logSink.writeln(message);
    // void out(String output) => outSink.write(output);

    for (final element in library.allElements) {
      if (element is ClassElement && !element.isEnum) {
        if (tapeTypeChecker.hasAnnotationOf(element)) {
          await _ensureTapeTypeAnnotationValid(log, element);
        }
      }
    }

    await logSink.close();
    return '/*Some generated code.*/';
  }

  Future<void> _ensureTapeTypeAnnotationValid(
    void Function(String) log,
    Element element,
  ) async {
    final trackingCodeValue =
        tapeTypeChecker.firstAnnotationOf(element).getField('trackingCode');
    final trackingCode =
        trackingCodeValue.isNull ? null : trackingCodeValue.toIntValue();

    if (trackingCode != null) {
      return;
    }

    // Insert a new tracking code into the source code.
    final span = spanForElement(element);
    log('Span is $span');
    final path =
        'lib/${span.sourceUrl.toString().substring('package:example/'.length)}';
    final file = await File(path).open(mode: FileMode.append);
    log('Changing file $path');

    // We got the span of the class name. The annotation is somewhere before
    // that, but we don't know exactly where. So we just assume it's somewhere
    // in the previous 512 bytes, if there are that many.
    final classStart = span.start.offset;
    final lookStart = max(0, classStart - 512);
    await file.setPosition(lookStart);
    final part = utf8.decode(await file.read(classStart - lookStart));
    for (var i = part.length - '@TapeType'.length - 1; i >= 0; i--) {
      log('Part is $part. Getting substring from $i');
      if (part.substring(i, i + '@TapeType'.length) == '@TapeType') {
        await file.setPosition(lookStart + i);
        break;
      }
    }
    while (true) {
      final byte = await file.readByte();
      if (byte < 0) return;
      if (byte == '(') break;
    }

    await file.writeString('testx');
    await file.close();

    log('uri=${element.librarySource.uri}');
    // log('contents=${element.librarySource.contents.data}');
    log('source=${element.librarySource.source}');
    log('span=${spanForElement(element)}');

    // Write to the source file.
    // final absolutePath =
    //     element.librarySource.source.fullName; // /example/lib/main.dart
    // final pathFromRoot = absolutePath.substring(1); // example/lib/main.dart
    // final pathFromProject =
    //     pathFromRoot.substring(pathFromRoot.indexOf('/') + 1); // lib/main.dart
    log('location_components=${element.location.components}');
    log('location_encoding=${element.location.encoding}');
    log('location_type=${element.location.runtimeType}');

    final classElement = element as ClassElement;
    final classToTape = ConcreteTapeType.fromElement(classElement);
    log(json.encode(classToTape));
  }
}

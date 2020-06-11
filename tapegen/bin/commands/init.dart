import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:dartx/dartx.dart';

import '../console.dart';
import '../files/main_dart.dart';
import '../files/tape_dart.dart';
import '../tapegen.dart';
import '../utils.dart';

/// Helps the developers integrate tape into their app.
final init = Command(
  names: ['init', 'i'],
  description: 'create tape boilerplate for your project',
  action: (List<String> args) async {
    await tapeDartFile.createAndInitialize();
    await mainDartFile.addCallToInitializeTape();

    return 0;
  },
);

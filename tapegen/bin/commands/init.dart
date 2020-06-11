import '../files/main_dart.dart';
import '../files/tape_dart.dart';
import '../tapegen.dart';

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

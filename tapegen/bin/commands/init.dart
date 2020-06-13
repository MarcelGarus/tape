import '../files/main_dart.dart';
import '../files/tape_dart.dart';
import '../tapegen.dart';
import '../utils.dart';

/// Helps the developers integrate tape into their app.
final init = Command(
  names: ['init', 'i'],
  description: 'create tape boilerplate for your project',
  action: (List<String> args) async {
    makeSureNoMoreArguments(args);

    await tapeDartFile.createAndInitialize();
    await mainDartFile.addCallToInitializeTape();
    // await tapeDartFile.registerAdapters([
    //   AdapterToRegister('AdapterForFruit()'),
    //   AdapterToRegister('AdapterForFoo()'),
    // ]);

    return 0;
  },
);

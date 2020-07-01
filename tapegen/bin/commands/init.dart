import 'package:pubspec_parse/pubspec_parse.dart';

import '../console.dart';
import '../files/main_dart.dart';
import '../files/pubspec_yaml.dart';
import '../files/tape_dart.dart';
import '../tapegen.dart';
import '../utils.dart';

/// Helps the developers integrate tape into their app.
final init = Command(
  names: ['init', 'initialize'],
  description: 'create tape boilerplate for your project',
  action: (args) async {
    final isForPackage = args.remove('--package');
    var isConfirmed = args.remove('--confirmed');
    makeSureNoMoreArguments(args);

    if (isForPackage) {
      if (!isConfirmed) {
        isConfirmed = await confirm('Do you want to overwrite '
            'lib/TODO_taped.dart, README.md, LICENSE, test/TODO_taped_test.dart '
            'and pubspec.yaml?');
      }
      if (!isConfirmed) {
        print('Aborting.');
        return -1; // TODO(marcelgarus): decide on return value
      }

      final task = Task(
        descriptionPresent: 'Changing pubspec.yaml description',
        descriptionPast: 'Changed pubspec.yaml description',
      );
      final parsedPubspec = Pubspec.parse(await pubspecYamlFile.read(task));
      var projectName = parsedPubspec.name;
      if (projectName == null || !projectName.endsWith('_taped')) {
        throw "Package \"$projectName\" doesn't end with \"_taped\".";
      }
      projectName =
          projectName.substring(0, projectName.length - '_taped'.length);
      await pubspecYamlFile.setDescriptionTo('A package containing tape '
          'adapters for $projectName. Intended to be used with $projectName '
          'and tape.');

      // TODO(marcelgarus): Replace default readme.
      // TODO(marcelgarus): Replace license.
      // TODO(marcelgarus): Replace lib/TODO_taped.dart.
      // TODO(marcelgarus): Replace test/TODO_taped_test.dart.
    } else {
      await tapeDartFile.createAndInitialize();
      await mainDartFile.addCallToInitializeTape();
    }

    return 0;
  },
);

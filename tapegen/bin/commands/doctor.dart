import 'dart:io';

import 'package:pubspec_parse/pubspec_parse.dart';

import '../console.dart';
import '../tapegen.dart';
import '../utils.dart';

final doctor = Command(
  names: ['doctor', 'doc', 'dr'],
  description: 'information about the usage of tape in your project',
  action: (List<String> args) async {
    makeSureNoMoreArguments(args);

    print('Running tape doctor. Allons-y!'); // Doctor Who reference.
    print('');

    // TODO: Check if a new version of tape is available.

    final pubspec = Pubspec.parse(File('pubspec.yaml').readAsStringSync());

    printTitle('Setup information:');
    print('${Platform.operatingSystemVersion}');
    print('Dart ${Platform.version}');
    if (pubspec.homepage != null) {
      print('Homepage: ${pubspec.homepage}');
    }
    if (pubspec.repository != null) {
      print('Repository: ${pubspec.repository}');
    }
    print('tape: ${_getDependencyInfos(pubspec.dependencies['tape'])}');
    print(
        'tapegen: ${_getDependencyInfos(pubspec.devDependencies['tapegen'])}');
    print('');

    // Tape-related packages.
    printTitle('Taped-packages:');

    final tapedPackages = pubspec.dependencies.entries
        .where((entry) => entry.key.endsWith('_taped'))
        .toList();
    for (final package in tapedPackages) {
      print('${package.key}: ${_getDependencyInfos(package.value)}');
    }

    return 0;
  },
);

String _getDependencyInfos(Dependency dependency) {
  if (dependency == null) {
    return 'missing';
  }
  if (dependency is GitDependency) {
    // TODO: Make this more beautiful. Most of the values will be null.
    return '${dependency.url}, using ref ${dependency.ref} from path ${dependency.path}';
  }
  if (dependency is PathDependency) {
    return 'from path ${dependency.path}';
  }
  if (dependency is HostedDependency) {
    return dependency.version.toString();
  }

  assert(false, 'Unknown dependency type ${dependency.runtimeType}');
}

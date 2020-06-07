import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:meta/meta.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

/// Will generate a tape.lock file:
/// ```yaml
/// types:
///   0:
///     fields:
/// ```

class LockFileBuilder implements Builder {
  @override
  final buildExtensions = const {
    r'$lib$': ['tape.lock']
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final exports = buildStep.findAssets(Glob('**/*.g.dart'));
    final content = [
      await for (var exportLibrary in exports)
        'adapter: ${await buildStep.readAsString(exportLibrary)};',
    ];
    if (content.isNotEmpty) {
      buildStep.writeAsString(
        AssetId(buildStep.inputId.package, 'tape.lock'),
        content.join('\n'),
      );
    }
  }
}

/// Representation of the `tape.lock` file in the project root folder.
/// Contains information about classes annotated with `@TapeClass`.
///
/// Here's an example of a `tape.lock` file. It contains a map from field id to
/// fields and field types. For example, type 0 contains two fields. Field 0 is
/// of a built-in type, field 1 is of type 0 (the type contains itself
/// recursively):
///
/// ```yaml
/// version: 1.0.0
/// types:
///   - 0: [0: -3, 1: 0]
///   - 1: [1: 0, 2: 3]
///   - 3: [0: 1, 1: 1]
/// ```
class LockFile {
  LockFile({
    @required this.version,
    @required this.types,
  });

  final Version version;
  final List<LockedTapeClass> types;

  factory LockFile.fromYaml(String yamlString) {
    final data = loadYaml(yamlString);
    return LockFile(
      version: Version.parse(data['version'] as String),
      types: [
        for (final entry in (data['types'] as Map<dynamic, dynamic>).entries)
          LockedTapeClass(
            id: entry.key as int,
            fields: [
              for (final field in (entry.value as Map<dynamic, dynamic>).values)
                LockedTapeField(
                  id: field.key as int,
                  typeId: field.value as int,
                ),
            ],
          ),
      ],
    );
  }

  String toYaml() {
    final buffer = StringBuffer();
    buffer
      ..writeln('# 📼.🔒')
      ..writeln('# This file should be checked into version control. Do not '
          'edit it by hand!')
      ..writeln('# Instead, run `pub run build_runner build` to re-generate '
          'this file.')
      ..writeln()
      ..writeln("# Btw, this file is in yaml format. Here's more information "
          "about this file:")
      ..writeln('# TODO')
      ..writeln()
      ..writeln('version: $version')
      ..writeln('types:');
    for (final type in types) {
      buffer
        ..write('  - ${type.id}: [ ')
        ..write([
          for (final field in type.fields) '${field.id}: ${field.typeId}',
        ].join(', '))
        ..writeln(' ]');
    }

    return buffer.toString();
  }
}

/// A concrete class that has been annotated with `@TapeType()` and that has a
/// generated and registered adapter.
/// Every tape type `T` should have an adapter named `AdapterForT` that is
/// registered in the `tape.dart` file using `Tape.registerAdapters` or in a
/// third-party package using `Tape.registerReservedAdapters`.
class LockedTapeClass {
  LockedTapeClass({
    @required this.id,
    @required this.fields,
  }) : assert(fields != null);

  final int id;
  final List<LockedTapeField> fields;
}

class LockedTapeField {
  LockedTapeField({
    @required this.id,
    @required this.typeId,
  })  : assert(id != null),
        assert(typeId != null);

  final int id;
  final int typeId;
}

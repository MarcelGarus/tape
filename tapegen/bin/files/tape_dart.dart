import '../ast_utils.dart';
import '../console.dart';
import '../errors.dart';
import '../utils.dart';

final tapeDartFile = File('lib/tape.dart');

class AdapterToRegister {
  AdapterToRegister(this.name) : assert(name != null);

  final String name;
}

class AdapterRegistration {
  AdapterRegistration(this.id, this.adapter)
      : assert(id != null),
        assert(adapter != null);

  final int id;
  final AdapterToRegister adapter;
}

extension _AdapterRegistration on CompilationUnit {
  SetOrMapLiteral get registrationMap {
    return topLevelFunctions
        .withName('initializeTape')
        ?.bodyBlock
        ?.statements
        ?.allExpressions
        ?.whereType<MethodInvocation>()
        ?.withName('registerAdapters')
        ?.map((invocation) => invocation.argumentList.arguments.singleOrNull)
        ?.whereType<SetOrMapLiteral>()
        ?.singleOrNull;
  }
}

T _debugPrint<T>(T obj) {
  print('\n$obj');
  return obj;
}

extension _MapEntries on SetOrMapLiteral {
  Iterable<MapLiteralEntry> get allEntries sync* {
    for (final element in elements) {
      if (element is MapLiteralEntry) {
        yield element;
      } else if (element is IfElement || element is ForElement) {
        throw UsedCollectionIfOrForError();
      } else if (element is SpreadElement) {
        final expression = element.expression;
        if (expression is SetOrMapLiteral) {
          yield* expression.allEntries;
        } else {
          throw ComplicatedExpressionInMapError();
        }
      } else if (element is Expression) {
        // Ignore this, the compiler will tell the user that expressions can
        // only be used in a set, not in a map literal.
      }
    }
  }
}

extension _Registrations on Iterable<MapLiteralEntry> {
  List<AdapterRegistration> get adapterRegistrations {
    final registrations = <AdapterRegistration>[];
    for (final entry in this) {
      final key = entry.key;
      final value = entry.value;
      if (key is! IntegerLiteral) {
        // Ignore this, the compiler will tell the user this is wrong.
        continue;
      }
      registrations.add(AdapterRegistration(
        key.as<IntegerLiteral>().value,
        AdapterToRegister(value.toSource()),
      ));
    }
    return registrations;
  }
}

extension TapeDartFile on File {
  Future<void> createAndInitialize() async {
    assert(this == tapeDartFile);
    final task = Task(
      descriptionPresent: 'Creating $normalizedPath...',
      descriptionPast: 'Created $normalizedPath.',
    );
    if (existsSync()) {
      task.success('Tape file already exists at $normalizedPath.');
      return;
    }

    try {
      await writeAsString(
        [
          "import 'package:tape/tape.dart';",
          "",
          "void initializeTape() {",
          "  // 📦 Register adapters from taped-packages.",
          "  //Tape",
          "  //  ..initializeFlutter()",
          "  //  ..initializeTimeTable()",
          "  //  ..initializeRrule();",
          "",
          "  Tape.registerAdapters({",
          "    // 🌱 For now, it's pretty empty here.",
          "    // Adapters for your types will be registered here.",
          "  });",
          "}",
          "",
        ].join('\n'),
        flush: true,
      );
    } catch (e) {
      task.error("Couldn't create tape file at $path.");
      return;
    }
    task.success('Created tape file at $path.');
  }

  Future<List<AdapterRegistration>> getRegisteredAdapters() async {
    final sourceCode = await read();
    return sourceCode.compile().registrationMap.allEntries.adapterRegistrations;
  }

  Future<void> registerAdapters(List<AdapterToRegister> adapters) async {
    final sourceCode = await read();
    final unit = sourceCode.compile();
    final map = unit.registrationMap;

    if (map == null) {
      throw NoRegistrationMapError();
    }

    final maxId = map.allEntries.adapterRegistrations
        .map((registration) => registration.id)
        .max();
    var nextId = maxId == null ? 0 : (maxId + 1);

    final offset = map.rightBracket.offset;
    final newCode = sourceCode.modify(() sync* {
      for (final adapter in adapters) {
        print('Registering adapter $adapter');
        yield Replacement.insert(
          offset: offset,
          replaceWith: '$nextId: ${adapter.name},',
        );
        nextId++;
      }
    });

    await write(newCode.formatted());
  }
}

⚠ This package is in early, early, early preview yet. Do not use in production.

---

You probably already know some serialization formats, the most famous being json. So, why do we need a new one?
Sadly, all of these encodings suffer from one of the following two problems:

* **Loss of type information:** For example, while you can implement a `user.toJson()` method so you can do `json.encode(someUser)`, you can't simply do `json.decode(...)` to get back the user. Rather, you need to call `User.fromJson(...)` — that means you need to know the type up-front.  
  This can be especially tricky when dealing with dynamic typing — good luck trying to parse some json that is either a `User` or a `FancyUser` without writing some complicated logic.  
  Even [<kbd>hive</kbd>](https://pub.dev/packages/hive) which uses a custom format, struggles with generic types and subclassing.
* **External definition:** Projects like Google's [ProtoBuf](https://developers.google.com/protocol-buffers) or [Cap'n Proto](https://capnproto.org/) can be a godsend if you're aiming for interoperability across multiple languages. But they rely on external definitions in a custom language as well as a custom compiler. That shifts the source of truth away from your Dart code and adds a lot of overhead and friction. For simple app-internal types that's often not worth it.

Meet [<kbd>tape</kbd>](https://pub.dev/packages/tape), a truly type-safe encoding (although you need to register types first).
Use `tape(...)` to turn an object into some bytes and `untape(...)` to turn those bytes back into an object – retaining all the type information.

Additional features include:

* **Small encoding**: The encoding is a custom binary format and magnitudes more efficient than json.
* **Future- and backwards-compatible.** When adding, renaming, or removing fields, you can deserialize values that have been serialized with previous or future versions. That means, saving taped objects for a long time or sending them to other phones is fine, no matter which version of your code is used.
* **Helpful tapegen:** Because adapters need to be generated for each type, you have to annotate types that you want to make tapeable. Luckily, besides actually generating the adapters, the [<kbd>tapegen</kbd>](https://pub.dev/packages/tapegen) tool also helps you with annotating types and alerts you when you make backwards-incompatible changes to them (TODO: it doesn't yet).
* **Extensible API** for publishing serializations for external types. If a package introduces custom data types, it's worth checking if someone wrote a `taped_…` package for it. For example, there's a `taped_flutter` package (there is not yet), that makes `Color`, … tapeable.
* **Compatible with [<kbd>freezed</kbd>](https://pub.dev/packages/freezed)**. That makes your type definitions even shorter.

## How to use?

First, add the following dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  tape:

dev_dependencies:
  build_runner:
  tapegen: # Contains code generators
```

In your project root directory, run `pub run tapegen init`.  
This will generate a `tape.dart` file next to your `main.dart` file. This file contains an `initialize` method that registers all your types.
Also, your `main` method now calls that `initialize` method (todo: tapegen init is not working yet):

```dart
import 'tape.dart' as tape;

void main() {
  tape.initialize();
  ...
}
```

If you want to serialize a type defined in your package, it's worth running `pub run tapegen`. This tool will help you annotating your types.  
Just annotate a class with `@TapeClass`:

```dart
@TapeClass
class User {
  User(this.firstName, this.lastName);

  final String firstName;
  final String lastName;
}
```

As soon as you save the file, <kbd>tapegen</kbd> will spring to live and help your annotate all the fields:

```dart
part 'my_file.g.dart';

@TapeClass(nextFieldId: 2)
class User {
  User(this.firstName, this.lastName);

  @TapeField(0)
  final String firstName;

  @TapeField(1)
  final String lastName;
}
```

In tape, every field has an id that uniquely identifies it. If you add, reorder, rename or delete fields, previous encodings are still valid. This is different from, say, json, where if you change a field name, it usually also changes in the json encoding itself.  

If you add a field and have <kbd>tapegen</kbd> running, the `@TapeField` annotation will automatically get added.
If you have a field that you don't want to tape, annotate it with `@DoNotTape` instead of `@TapeField`.

When you're done annotating your types, run `pub run build_runner build` to actually generate the adapters for those types.

Then, register them in your `tape.dart`.

## How does the encoding work?

TODO

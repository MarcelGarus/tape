You probably already know some serialization formats, the most famous being json. So, why do we need a new one?
Sadly, all of these encodings suffer from one of the following two problems:

* **Loss of type information:** For example, while you can implement a `user.toJson()` method so you can do `json.encode(someUser)`, you can't simply do `json.decode(...)` to get back the user. Rather, you need to call `User.fromJson(...)` — that means you need to know the type up-front.  
  This can be especially tricky when dealing with dynamic typing — good luck trying to parse some json that is either a `User` or a `FancyUser` without writing some complicated logic.  
  Even projects like [<kbd>hive</kbd>](https://pub.dev/packages/hive) that use custom formats, struggle with generic types and subclassing.
* **External definition:** Projects like Google's [ProtoBuf](https://developers.google.com/protocol-buffers) or [Cap'n Proto](https://capnproto.org/) can be a godsend if you're aiming for interoperability across multiple languages. But they rely on external definitions in a custom language as well as a custom compiler. That shifts the source of truth away from your Dart code and adds a lot of overhead and friction. For simple app-internal types that's often not worth it.

Meet [<kbd>tape</kbd>](https://pub.dev/packages/tape), a truly type-safe encoding (although you need to register types first).
Use `tape(...)` to turn an object into some bytes and `untape(...)` to turn those bytes back into an object – retaining all the type information.

Additional features include:

* **Helpful code generator:** The code generator helps you by modifying code and alerting you when you make backwards-incompatible changes to the types.
* **Extensible API** for publishing serializations for external types. If a package introduces custom data types, it's worth checking if someone wrote a `taped_…` package for it. For example, there's a `taped_flutter` package, that makes `Color`, … tapeable.
* **Compatible with other code-gen packages,** like [<kbd>freezed</kbd>](https://pub.dev/packages/freezed). Using some functionality shouldn't make you sacrifice on other parts.
* **Future- and backwards-compatible.** When adding or removing fields, you can deserialize values that have been serialized with previous or future versions. That means, saving taped objects for a long time or sending them to other phones is fine.
  That even works when renaming fields

That being said, there's some overhead involved to be able to serialize custom types:

## How to use?

First, add the following dependencies to your `pubspec.yaml`:

```dart
dependencies:
  tape:

dev_dependencies:
  build_runner:
  tapegen:
```

In your project root directory, run `pub run tape init`.

This will generate a `tape.dart` file next to your `main.dart` file. This file will contain an `initialize` method that registers all your types.
Also, you `main.dart` file now calls that `initialize` method:

```dart
import 'tape.dart' as tape;

void main() {
  tape.initialize();
  ...
}
```

Next up, it's time to register some types to tape. Each type will need a `TapeAdapter`. Luckily, we can automatically generate that most of the time! Just run `pub run build_runner watch` in your project root.

Open a file that contains a type you want to serialize. Just add `part 'file_name.g.dart';` at the top and annotate your type with `@TapeAll`:

```dart
part 'user.g.dart';

@TapeAll
class User {
  User(this.firstName, this.lastName);

  final String firstName;
  final String lastName;
}
```

As soon as you hit save, the `@TapeAll` annotation will get replaced with a `@TapeType(...)` annotation that contains some cryptic String — don't worry about that for now. Also, all the fields should get annotated with `@TapeField(someId)`.

In tape, every field has an id that uniquely identifies it. When you rename the field, previous encodings are still valid. This is different from, say, json, where if you change a field name, it usually also changes in the json code itself.  
By the way: The field ids automatically count up. If you add a new field, just annotate it with `@TapeField()` and hit save — <kbd>tapegen</kbd> will fill out the id for you.
Also, feel free to remove or reorder fields along with their annotations.


## How does the encoding work?

**Won’t fixed-width integers, unset optional fields, and padding waste space on the wire?**

Yes. However, since all these extra bytes are zeros, when bandwidth matters, we can apply an extremely fast Cap’n-Proto-specific compression scheme to remove them. Cap’n Proto calls this “packing” the message; it achieves similar (better, even) message sizes to protobuf encoding, and it’s still faster.

When bandwidth really matters, you should apply general-purpose compression, like zlib or LZ4, regardless of your encoding format.

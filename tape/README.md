You probably already know some serialization formats, the most famous being json. So, why do we need a new one?
Sadly, all of these encodings suffer from one of the following two problems:

* **Loss of type information:** For example, while you can implement a `user.toJson()` method so you can do `json.encode(someUser)`, you can't simply do `json.decode(...)` to get back the user. Rather, you need to call `User.fromJson(...)` — that means you need to know the type up-front.  
  This can be especially tricky when dealing with dynamic typing — good luck trying to parse some json that is either a `User` or a `FancyUser` without writing some complicated logic.  
  Even projects like [<kbd>hive</kbd>](https://pub.dev/packages/hive) that use custom formats, struggle with generic types and subclassing.
* **External definition:** Projects like Google's [ProtoBuf](https://developers.google.com/protocol-buffers) or [Cap'n Proto](https://capnproto.org/) can be a godsend if you're aiming for interoperability across multiple languages. But because they're relying on external definitions in a custom language as well as a custom compiler, there's more syntax to learn and more tooling to install. When implementing some simple app-internal types, the overhead and friction they add is often not worth it.

Meet [<kbd>tape</kbd>](https://pub.dev/packages/tape), a truly type-safe encoding.
Use `tape(...)` to turn an object into some bytes and `untape(...)` to turn those bytes back into an object – retaining all the type information.

Additional features include:

* **Support for generic types.** Saving a `List<T>` doesn't drop the type information of `T` — even when storing nothing in the list or storing only subclasses, like `<Object>[4, "Hi"]`.
* **Extensible API** for publishing serializations for external types. If a package introduces custom data types, it's worth checking if someone wrote a `taped_…` package for it. For example, there's a `taped_flutter` package, that makes `Color`, … tapeable.
* **Compatible with other code-gen packages,** like [<kbd>freezed</kbd>](https://pub.dev/packages/freezed). Using some functionality shouldn't make you sacrifice on other parts.
* **Future- and backwards-compatible.** When adding or removing fields, you can deserialize values that have been serialized with previous or future versions. That means, saving taped objects for a long time or sending them to other phones is fine.
  That even works when renaming fields

That being said, there's some overhead involved to be able to serialize custom types:

## How to use?

- Just annotate your class and fields with `@TapeType` and `@TapeField`, respectively:

  ```dart
  @TapeType()
  class Fruit {
    Fruit({
      this.color,
      this.someMappedInts,
      this.pointer,
    });

    @TapeField(0)
    final Set<T> someItems;

    @TapeField(1)
    final Map<int, bool> someMappedInts;

    @TapeField(2)
    final MyClass<String> pointer;
  }
  ```
- Run `flutter pub run build_runner build` (or, if you're running a pure Dart project, `pub run build_runner build`).
- ```dart
  
  ```

## How does the encoding work?

**Won’t fixed-width integers, unset optional fields, and padding waste space on the wire?**

Yes. However, since all these extra bytes are zeros, when bandwidth matters, we can apply an extremely fast Cap’n-Proto-specific compression scheme to remove them. Cap’n Proto calls this “packing” the message; it achieves similar (better, even) message sizes to protobuf encoding, and it’s still faster.

When bandwidth really matters, you should apply general-purpose compression, like zlib or LZ4, regardless of your encoding format.

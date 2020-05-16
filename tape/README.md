You probably already know at least some serialization formats for Dart objects, the most famous being json. So, why did I invent a new one?
Sadly, all of these encodings suffer from one of the following two problems:

* **Loss of type information:** For example, you can implement a `user.toJson()` method to turn a user into json, but you can't simply do `json.decode(...)` to get back the user. Rather, you need to call `User.fromJson(...)`, so you need to know the type up-front.  
  This can be especially tricky when dealing with subclasses — good luck trying to store a variable that is either a `User` or a `FancyUser` without writing some complicated logic.  
  Even projects like [<kbd>hive</kbd>](https://pub.dev/packages/hive) that use custom formats, struggle with generic types and subclassing.
* **External definition:** Projects like Google's [ProtoBuf](https://developers.google.com/protocol-buffers) or [Cap'n Proto](https://capnproto.org/) can be a godsend if you're aiming for interoperability across multiple languages. But because they're relying on external definitions in a custom language as well as a custom compiler, there's more syntax to learn and more tooling to install. When implementing some simple app-internal types, the overhead and friction they add is often not worth it.

## How to use?

Just annotate your class and fields with `@TapeType` and `@TapeField`, respectively:

```dart

@TapeType()
class MyClass<T> {
  MyClass({
    this.someItems,
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

## How does the encoding work?

**Won’t fixed-width integers, unset optional fields, and padding waste space on the wire?**

Yes. However, since all these extra bytes are zeros, when bandwidth matters, we can apply an extremely fast Cap’n-Proto-specific compression scheme to remove them. Cap’n Proto calls this “packing” the message; it achieves similar (better, even) message sizes to protobuf encoding, and it’s still faster.

When bandwidth really matters, you should apply general-purpose compression, like zlib or LZ4, regardless of your encoding format.

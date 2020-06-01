## Tape

Welcome to the tape repository!
This readme will focus on how tape is architectured and on how it works internally.
For more general information about what tape is, see [this other readme](tape/README.md).

Tape is divided into the following layers:

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ tape assist                         ┃
┣━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━┫
┃ adapter generation ┃ taped-packages ┃
┣━━━━━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━━┫
┃ adapter framework                   ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃ block framework                     ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

* **Block framework:** Turns `Block`s (declarative low-level primitives like `Uint8Block` or `ListBlock`) into bytes and the other way around.
* **Adapter framework:** Provides the primitives for writing, registering and looking up adapters.
* **Adapter generation:** Code generation of adapters based on annotations like `@TapeClass`. Also checks and ensures backwards-compatibility.
* **Taped-packages:** Ecosystem of packages named `taped_...` for types from pub.dev packages. Maintained by the community.
* **Tape assist:** Tool helping you annotate classes, as well as looking for and initializing taped-packages.

Apart from some community-maintained taped-packages, most of the layers exist within these repository. The top folders represent pub.dev packages:

* `tape` contains things used during runtime to actually encode the values. That's the block and adapter framework.
* `tapegen` contains things related to code generation and improving experience during development – adapter generation and tape assist.

### Writing custom adapters

Most of the time, using the adapter generator is fine. Here are some cases where you might need to create your own:

- You're using a package that has a custom type and no taped-package exists for it.
- You're publishing a package with a custom type and you want users to be able to tape that type without littering your original package with adapters.
- You want the encoding to be more efficient.

If your type is a class, just extend `TapeClassAdapter<TheType>`.
In the `toFields(TheType object)` method, return a `Fields` class that maps all these fields to unique ids:

```dart
class AdapterForTheType extends TapeClassAdapter<TheType> {

  @override
  Fields toFields(TheType object) {
    return Fields({
      0: object.someString,
      1: object.dynamicField,
      2: Int8(object.smallInt),
    });
  }

  @override
  TheType fromFields(Fields fields) {
    return TheType(
      someString: fields.get<String>(0, orDefault: ''),
      dynamicField: fields.get<dynamic>(1, orDefault: null),
      smallInt: fields.get<Int8>(2, orDefault: Int8.zero).toInt(),
    );
  }
}
```

#### Publishing a taped-package

If you want to publish the package to pub.dev, consider naming it `taped_<name of the original package>`.
For example, if your package is named `sample`, it would be `taped_sample`.  
Adhering to this naming scheme allows tape assist to automatically find that package and suggest it to users when they add a `@TapeClass` annotation to a class that contains a field of a type from your package.

Also, you should give your adapter a negative type id to not interfere with the adapters created by the end-user. File a PR for reserving a type id in the [table of reserved type ids](table_of_type_ids.md).

Additionally, add a `tape.dart` to your package root (so it can be imported with `import 'package:taped_sample/tape.dart';`) with the following content:

```dart
extension InitializeSample on TapeApi {
  void initializeSample() {
    registerAdapters({
      // Use your reserved type ids here.
      -4: AdapterForTheType(),
      -5: AdapterForOtherType(),
      ...
    });
  }
}
```

### Behind the scenes: Searching for the right adapter

> Note: This is not up-to-date.

Adapters are stored in a tree, like the following:

```
root node for objects to serialize
├─ virtual node for Iterable<Object>
│  ├─ AdapterForRunes
│  │  └─ AdapterForNull
│  └─ ...
├─ virtual node for int
│  ├─ AdapterForUint8
│  ├─ AdapterForInt8
│  ├─ AdapterForUint16
│  ├─ AdapterForInt16
│  ├─ AdapterForUint32
│  ├─ AdapterForInt32
│  └─ AdapterForInt64
├─ virtual node for bool
│  ├─ AdapterForTrueBool
│  └─ AdapterForFalseBool
├─ virtual node for String
│  ├─ AdapterForStringWithoutNullByte
│  └─ AdapterForArbitraryString
├─ AdapterForDouble
└─ ...
```

You can always get such a tree visualization of the adapter tree by calling `TypeRegistry.debugDumpTree()`.

Additionally, the `TypeRegistry` contains a map of shortcuts from types to nodes in the tree.

### Behind the scenes: How is data encoded

See [The Life of a Fruit](the_life_of_a_fruit.md).

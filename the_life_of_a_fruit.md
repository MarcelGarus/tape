# The Life of a Fruit

We'll look at complete example encoding from an `Object` to bytes.

Meet this `Fruit` class:

```dart
@TapeClass(nextFieldId: 3)
class Fruit {
  Fruit({this.name, this.amount, this.isRipe});

  @TapeField(0, defaultValue: '')
  String name;
  
  @TapeField(1, defaultValue: 0)
  int amount;

  @TapeField(2, defaultValue: false)
  bool isRipe;
}
```

And assume the adapter is registered like this in your `tape.dart`:

```dart
Tape.registerAdapters({
  0: AdapterForFruit(),
});
```

And also, have this apple:

```dart
var apple = Fruit(name: 'apple', amount: 42, isRipe: true);
```

Now, imagine you call `tape.encode(apple)`. What exactly happens?

To give you a little bit of structure, this is how the encoding pipeline looks:  
`Object` → **use adapters** → `Block` → **serialize blocks** → `Uint8List` → **compress** → `Uint8List`

So, first `Object`s are turned into `Block`s, those into bytes and those are compressed into less bytes.

## `Fruit` to `Block`

The adapter framework has an `adapters.encode` method that takes an `Object` and finds the corresponding adapter.
To turn `anObject` into `Block`s, it then calls the adapter's `toBlocks(anObject)` method.

So, internally, it does `adapters.encode(apple)`, finds the `AdapterForFruit` and calls its `toBlock` method.
Here's how the generated adapter looks like:

```dart
class AdapterForFruit extends TapeClassAdapter<Fruit> {
  const AdapterForFruit();

  @override
  Fruit fromFields(Fields fields) {
    return Fruit(
      name: fields.get<String>(0, orDefault: null),
      amount: fields.get<int>(1, orDefault: null),
      isRipe: fields.get<bool>(2, orDefault: null),
    );
  }

  @override
  Fields toFields(Fruit object) {
    return Fields({
      0: object.name,
      1: object.amount,
      2: object.isRipe,
    });
  }
}
```

Wait. It doesn't even contain a `toBlock` method!
That's because it's a `TapeClassAdapter`, which extends `TapeAdapter` and takes care of the `toBlock` and `fromBlock` methods for us. Here's how `toBlock` is implemented:

```dart
Block toBlock(T object) {
  return FieldsBlock({
    for (final field in toFields(object)._fields.entries)
      field.key: adapters.encode(field.value),
  });
}
```

So it calls `toFields` and every field value is also encoded using adapters (which again, are also looked up by the runtime type).
So, because our `apple` contains a `String`, `int`, and `bool` value, the `AdapterForString`, `AdapterForInt`, and `AdapterForBool` are chosen.

> Note that adapters are looked up based on the object's *runtime* type, not the static type known at compile time. If any of the values were `null`, the `AdapterForNull` would be chosen. Similarly, this allows for using subclasses as fields.

For every call, `adapters.encode` also wrap the call in a `TypedBlock` that stores the adapter's id.
Note that the ids of built-in adapters are negative.
This results in a structure of `Block`s that looks like this:

```dart
TypedBlock(
  typeId: 0, // id of AdapterForFruit
  child: FieldsBlock({
    0: TypedBlock(
      typeId: -3, // id of AdapterForString
      child: BytesBlock([97, 112, 112, 108, 101]),
    ),
    1: TypedBlock(
      typeId: -4, // id of AdapterForInt
      child: IntBlock(42),
    ),
    2: TypedBlock(
      typeId: -2, // id of AdapterForBool
      child: Uint8Block(1),
    ),
  })
)
```

As you see, adapters already broke down complex types into a tree of blocks – the `String` became a `BytesBlock` containing the utf8-encoded bytes and the `bool` became a `Uint8Block` containing a single byte that is 1 to indicate it's true.

## `Block` to bytes

Now that we got a tree of `Block`s that only contains some pre-defined primitive types, this is serialized into bytes by traversing the tree depth-first.

Every `Block` has it's own id that is only one byte (because there are only a handful of `Block`s).
`Block`s that can have a variable length when encoded first save how long they are (that is, in bytes or number of fields or something like that).

Have a look at the encoding of the adapters above, written in a tree structure and annotated with comments:

```
0                     // Now, a TypedBlock is coming. TypedBlocks saves the typeId and their child.
  0 0 0 0 0 0 0 0 0 0 // The typeId (this is the id of the AdapterForFruit).
  1                   // The child is a FieldsBlock. It saves the number of fields and then field ids with values.
    0 0 0 3           // There are three fields saved here.
    0 0 0 0                           // This is the field with id 0.
    0                                 // The value of field 0 is a TypedBlock.
      255 255 255 255 255 255 255 253 // The type id is -3 (AdapterForString)
      2                               // The child is a BytesBlock. It saves the length and then the bytes.
        0 0 0 0 0 0 0 5               // There are 5 bytes coming.
        97                            // a
        112                           // p
        112                           // p
        108                           // l
        101                           // e
    0 0 0 1                           // Now comes the field with id 1.
    0                                 // It's also a TypedBlock.
      255 255 255 255 255 255 255 252 // The type id is -4 (AdapterForInt)
      4                               // This is an IntBlock. It just saves the int value.
        0 0 0 0 0 0 0 42              // The value is 42.
    0 0 0 2                           // Now, the field with id 2.
    0                                 // Again, a TypedBlock.
      255 255 255 255 255 255 255 254 // Type id is -2 (AdapterForBool).
      5                               // A Uint8Block. Just saves its value as a byte.
        1                             // Indicates true.
```

Phew! As you see, each `Block` has a predefined encoding scheme. You can look at all of them [here](https://github.com/marcelgarus/tape/tree/master/tape/lib/src/blocks/blocks) – it's documented right in the source code.

Great! So now, we got ourselves a list of bytes:  
`0 0 0 0 0 0 0 0 0 1 0 0 0 3 0 0 0 0 0 255 255 255 255 255 255 255 253 2 0 0 0 0 0 0 0 5 97 112 112 108 101 0 0 0 1 0 255 255 255 255 255 255 255 252 4 0 0 0 0 0 0 0 42 0 0 0 2 0 255 255 255 255 255 255 255 254 5 1`

## From bytes to less bytes

> Note: This is not implemented yet.

By looking at the bytes, you can easily see that there is small entropy there – most of the bytes are `0` or `255`.
So we compress them using a simple approach: After a `0`, just take one byte to save how many other `0` are coming.
So a `0 0 0` could be compressed to `0 2` (a zero and there are two more coming after it).
The same goes for `255`.

> Note that while this sometimes makes the encoding longer (for example, `0 1` becomes `0 0 1`), most of the time it's worth it.

This gives us the following encoding:

`0 8 1 0 2 3 0 4 255 6 253 2 0 6 5 97 112 112 108 101 0 2 1 0 0 255 6 252 4 0 6 42 0 2 2 0 0 255 6 254 5 1`

TODO: Can we somehow encode type ids differently so that even negative ones contain lots of zeroes? This is how the encoding would look like if every `255` bit was `0` instead:

`0 8 1 0 2 3 0 11 253 2 0 6 5 97 112 112 108 101 0 2 1 0 7 252 4 0 6 42 0 2 2 0 7 254 5 1`

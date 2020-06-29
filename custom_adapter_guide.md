## Writing custom adapters

Don't.

Except you can't use code generation, for example, because you're planning on publishing your adapters on pub.dev.

As tape [values usability](values.md), be **very sure** that you'll be able to handle future changes.

To get familiar with the encoding pipeline, I recommend reading [The Life of a Fruit](the_life_of_a_fruit.md).  
Here are some things to consider when writing adapters:

### Don't optimize for space

Most of the devices we use have sufficient memory so that space doesn't really matter a lot when saving data.
There are of course some situations where it *does* matter, for example, if you have a reeeally big database or want to transmit serialized data over network.

In these cases, the encoding step is just not the right place optimize a few bytes.
Efficiency in encoding usually comes at the cost of less extensibility and resistance to changes.
And humans are bad at optimizing for space efficiency while also worrying about extensibility – at least worse than general-purpose compression algorithms like gzip, which are explicitly built to reduce entropy aggressively.

So, if space efficiency is really a concern for you, you should apply something like gzip to the output of tape.

### Extend `TapeClassAdapter` whenever possible

You only need to return `Fields` and you also get `Fields` to create an object from.
The conversion from those `Fields` to `Block`s gets handled by the `TapeClassAdapter` automatically.

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

### Use `TapeAdapter`s only if you really need to.

Here, you need to handle the conversion from and to `Block`s yourself.
Also, you'll need to guarantee that this adapter produces sensible values for *all future adapter implementations*, so you'll need to settle on a block structure that is extensible enough for any changes that might happen.

For types that are very very unlikely to change, you might also use a more efficient encoding, like the following:

```dart
class AdapterForColor extends TapeAdapter<Color> {
  @override
  Block toBlock(Color color) => Uint32Block(color.value);

  @override
  Color fromBlock(Block block) => Color(block.as<Uint32Block>().value);
}
```

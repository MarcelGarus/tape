# How to create a taped-package

Suppose you have a package named <kbd>sample</kbd> that contains some types you want to make serializable with tape.

First, check if a <kbd>sample_taped</kbd> package already exists.
If it does, just use it. If it doesn't contain the type you want to serialize, consider opening a pull request.

If no <kbd>sample_taped</kbd> package exists, it's time to create your own!  
To do that, [open an issue](https://github.com/marcelgarus/taped/issues/new?template=1-taped-package.md) for the new package.
[@marcelgarus](https://github.com/marcelgarus) will try to answer you soon-ish and add ids in the [holy table of type ids](table_of_type_ids.md).

Then, create a new project using

```bash
flutter create --template=package sample_taped
```

After that command ran successfully, add <kbd>tape</kbd> and <kbd>tapegen</kbd> in your `pubspec.yaml`:

```dart
dependencies:
  tape:

dev_dependencies:
  tapegen:
```

Note that you don't need the <kbd>build_runner</kbd>, because you won't be generating adapters automatically.

Navigate into the project folder and generate the taped-package boilerplate:

```bash
cd sample_taped
pub run tapegen init --package // TODO: make this work
```

Now, it's time to actually write adapters!
For more information about what role adapters play in the larger picture, it definitely makes sense to have a look at the [encoding pipeline](the_life_of_a_fruit.md).
Also, you might want to check out some adapters other people have written.

<!--
TODO: Insert more text about thinking about future compatibility etc.
Or insert a link to the custom adapter guide.
-->


```bash
pub run tapegen package pr-for-type-ids
```

It's time to wait! After your PR has been merged, just insert the type ids in the `sample_tape.dart` file of your package.

Then, publish your package using `pub lish`.

Finally, close the issue.

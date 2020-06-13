# The Table of Type IDs

If you are creating a Dart package that needs to register custom type adapters and that's intended to be published on [pub.dev](https://pub.dev), don't hesitate to file a pull request adding type ids to this table.

> TODO: This is not up-to-date.
>
> Consider adding something like the following to your package to allow users to call `binary.initializeMyPackage()`:
>
> ```dart
> extension MyPackageBinary on BinaryApi {
>   void initializeMyPackage() {
>     TypeRegistry.registerAdapters({
>       ...
>     });
>   }
> }
> ```

Type id reservations are done in batches of 10. The x stands for any digit.

| type ids | types from        | taped-package                                             | repository                                              |
| -------- | ----------------- | --------------------------------------------------------- | ------------------------------------------------------- |
| -1 – -9  | `dart:core`       | built-in                                                  | [marcelgarus/tape](https://github.com/marcelgarus/tape) |
| -1x      | `dart:core`       | built-in                                                  | [marcelgarus/tape](https://github.com/marcelgarus/tape) |
| -2x      | `dart:core`       | built-in                                                  | [marcelgarus/tape](https://github.com/marcelgarus/tape) |
| -3x      | `dart:core`       | built-in                                                  | [marcelgarus/tape](https://github.com/marcelgarus/tape) |
| -4x      | `dart:core`       | built-in                                                  | [marcelgarus/tape](https://github.com/marcelgarus/tape) |
| -5x      | `dart:core`       | built-in                                                  | [marcelgarus/tape](https://github.com/marcelgarus/tape) |
| -6x      | `dart:core`       | built-in                                                  | [marcelgarus/tape](https://github.com/marcelgarus/tape) |
| -7x      | `dart:core`       | built-in                                                  | [marcelgarus/tape](https://github.com/marcelgarus/tape) |
| -8x      | `dart:typed_data` | built-in                                                  | [marcelgarus/tape](https://github.com/marcelgarus/tape) |
| -9x      | `dart:math`       | built-in                                                  | [marcelgarus/tape](https://github.com/marcelgarus/tape) |
| -10x     | `flutter`         | [`flutter_taped`](https://pub.dev/packages/flutter_taped) | [marcelgarus/tape](https://github.com/marcelgarus/tape) |

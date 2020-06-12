/// Everything you need to create taped-packages.

export 'dart:typed_data';

export 'custom.dart'; // Authors of taped-packages need to write custom adapters.
export 'src/api.dart' hide RegisterAdapters;
export 'src/built_in/built_in.dart' hide registerBuiltInAdapters;
export 'src/codec.dart';
export 'src/errors.dart';

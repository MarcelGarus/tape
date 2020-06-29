/// Everything you need to create taped-packages.

export 'dart:typed_data';

export 'src/adapters/utils.dart' show BlockCast;
export 'custom.dart'; // Authors of taped-packages need to write custom adapters.
export 'src/api.dart' hide RegisterUserAdapters;
export 'src/built_in/built_in.dart';
export 'src/codec.dart';
export 'src/errors.dart';

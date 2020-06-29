/// Everything you need to use [tape] to serialize objects and to create
/// [TapeClassAdapter]s using annotations.

export 'dart:typed_data';

export 'src/adapters/adapters.dart' show adapters;
export 'src/annotations.dart';
export 'src/api.dart' hide RegisterPackageAdapters;
export 'src/built_in/built_in.dart';
export 'src/codec.dart';
export 'src/errors.dart';

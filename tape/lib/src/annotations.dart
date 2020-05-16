import 'package:meta/meta.dart';

/// Annotating a class with `@TapeType` indicates that a [TapeAdapter] should
/// get generated for it when running the `tape_generator`.
class TapeType {
  const TapeType({this.legacyFields = const {}}) : assert(legacyFields != null);

  /// Field ids that were used in the past and should not be used anymore.
  final Set<int> legacyFields;
}

/// Annotating a field in a `@TapeType` class with `@TapeField` indicates that
/// it should get serialization and deserialization code should get created for
/// it when running the `tape_generator`.
class TapeField {
  const TapeField(this.id, {@required this.defaultValue});

  /// An id that uniquely identifies this field among other fields of this
  /// class that currently exist, existed in the past, and will exist in the
  /// future.
  final int id;

  /// The default value of this field.
  ///
  /// If an object gets serialized, then a field gets added to an object, and
  /// then the object gets deserialized again, fields may be missing.
  /// This value indicates the value these fields should get in that case.
  final dynamic defaultValue;
}

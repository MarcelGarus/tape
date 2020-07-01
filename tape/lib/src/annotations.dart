import 'package:meta/meta.dart';

/// Annotating the call to `Tape.registerAdapters` with `@TapeInitialization`
/// indicates that `tapegen` should insert new tape adapters into the call.
class TapeInitialization {
  const TapeInitialization({@required this.nextTypeId})
      : assert(nextTypeId != null),
        assert(nextTypeId >= 0);

  final int nextTypeId;
}

/// Annotating a class with `@TapeClass` indicates that a `TapeAdapter` should
/// get generated for it when running `tapegen`.
class TapeClass {
  const TapeClass({@required this.nextFieldId})
      : assert(nextFieldId != null),
        assert(nextFieldId >= 0);

  /// The id of the next field to be inserted.
  final int nextFieldId;
}

/// Annotating a field in a `@TapeClass` class with `@TapeField` indicates that
/// it should get serialization and deserialization code should get created for
/// it when running `tapegen`.
class TapeField {
  const TapeField(this.id, {@required this.defaultValue}) : assert(id != null);

  /// An id that uniquely identifies this field among other fields of this
  /// class that currently exist, existed in the past, and will exist in the
  /// future.
  final int id;

  final dynamic defaultValue;
}

/// Annotating a field of a `@TapeClass` with `@doNotTape` indicates that the
/// generated shouldn't serialize it.
const doNotTape = DoNotTapeImpl();

class DoNotTapeImpl {
  const DoNotTapeImpl();
}

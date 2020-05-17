/// Annotating a class with `@TapeType` indicates that a [TapeAdapter] should
/// get generated for it when running the `tape_generator`.
class TapeType {
  const TapeType([this.nextFieldId, this.trackingCode]);

  /// The id of the next field to be inserted.
  final int nextFieldId;

  /// A code that uniquely identifies this types among others that are
  /// registered in the `tape.lock` file. If the `tape.lock` file gets deleted,
  /// this tracking code can also be deleted as it isn't used anywhere else.
  final String trackingCode;
}

/// Annotating a field in a `@TapeType` class with `@TapeField` indicates that
/// it should get serialization and deserialization code should get created for
/// it when running the `tape_generator`.
class TapeField {
  const TapeField([this.id]);

  /// An id that uniquely identifies this field among other fields of this
  /// class that currently exist, existed in the past, and will exist in the
  /// future.
  final int id;
}

const TapeAll = TapeAllImpl();

class TapeAllImpl {
  const TapeAllImpl();
}

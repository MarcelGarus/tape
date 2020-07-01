import '../ast_utils.dart';
import '../console.dart';
import '../utils.dart';

class AssistResult {
  AssistResult(this.tapeTypes);

  /// Found tape types as [String]s, for example, `"Foo"` or `"Bar<Foo>"`.
  final List<String> tapeTypes;
}

extension AnyDartFile on File {
  /// Assists with a single dart file.
  Future<AssistResult> assist([Task task]) async {
    final content = await read(task);
    final unit = content.compile(task);
    final tapeTypes = <String>[];

    task?.subtask('autocompleting');
    final newContent = content.modify(() sync* {
      final classes = unit.declarations?.whereType<ClassDeclaration>() ?? [];

      for (final declaration in classes.where((cls) => cls.isTapeClass)) {
        tapeTypes.add(declaration.name.toSource());
        yield* _autocompleteAnnotations(
          declaration,
          declaration.members.whereType<FieldDeclaration>().toList(),
        );
      }

      for (final declaration in classes.where((cls) => cls.isFreezed)) {
        final freezedTapeFactories = declaration.members
            .whereType<ConstructorDeclaration>()
            .where((constructor) => constructor.factoryKeyword != null)
            .where((c) => c.isTapeClass);
        for (final constructor in freezedTapeFactories) {
          tapeTypes.add(constructor.redirectedConstructor.toSource());
          yield* _autocompleteAnnotations(
            constructor,
            constructor.parameters.parameters,
            insertNewlineBeforeNewFieldAnnotations: false,
          );
        }
      }

      if (tapeTypes.isNotEmpty) {
        yield* _ensurePartOfDirectiveExists(unit);
      }
    });
    await write(newContent, task);

    task.success();
    return AssistResult(tapeTypes);
  }

  /// Annotates a structure annotated with `@TapeClass`.
  Iterable<Replacement> _autocompleteAnnotations(
    AstNode parentStructure,
    List<AstNode> fields, {
    bool insertNewlineBeforeNewFieldAnnotations = true,
    void Function() onNewlyDiscovered,
  }) sync* {
    /// A quick rundown of how this will work:
    /// - First, we find the [nextFieldId].
    /// - Then, we iterate over the fields and add annotations and/or field ids
    ///   where necessary. Everytime we need to insert a field id, we use
    ///   [nextFieldId] and then increase it by one.
    /// - After we annotated all the fields, we update the `@TapeClass` annotation
    ///   to contain the new, correct [nextFieldId].

    final tapeClassAnnotation = parentStructure.tapeClassAnnotation;
    assert(tapeClassAnnotation != null);

    /// Newly discovered classes have a `@TapeClass` annotation without any
    /// parenthesis after it.
    final isNew = !tapeClassAnnotation.toSource().contains('(');
    if (isNew) {
      onNewlyDiscovered();
    }

    /// Determine the next field id as
    /// - The `nextFieldId` parameter of the `@TapeClass` annotation.
    /// - If it doesn't have one, as the maximum field id of fields + 1.
    /// - If there are no `@TapeField`s with field ids, then default to 0.
    var nextFieldId = tapeClassAnnotation.nextFieldId;
    nextFieldId ??= fields
        .map((field) => field.tapeFieldAnnotation?.fieldId)
        .whereNotNull()
        .map((fieldId) => fieldId + 1)
        .max();
    nextFieldId ??= 0;

    for (final field in fields.where((field) => !field.doNotTape)) {
      final defaultValue = field.tapeFieldAnnotation?.defaultValue ??
          field.freezedDefaultAnnotation?.freezedDefaultValue ??
          'TODO'; // Purposely creates an error in the file.

      if (!field.isTapeField) {
        /// This field has no annotation although it is inside a `@TapeClass`.
        /// Add a `@TapeField` annotation.
        final prefix = insertNewlineBeforeNewFieldAnnotations ? '\n\n' : '';
        yield Replacement.insert(
          offset: field.offset,
          replaceWith:
              '$prefix@TapeField($nextFieldId, defaultValue: $defaultValue)\n',
        );
        nextFieldId++;
        continue;
      }

      /// This field is already annotated with a `@TapeField` annotation. Maybe it
      /// doesn't contain a field id or default value yet. If so, we finish the
      /// annotation.
      final annotation = field.tapeFieldAnnotation;
      final fieldId = annotation.fieldId;

      if (fieldId == null) {
        yield Replacement.forNode(
          annotation,
          '@TapeField($nextFieldId, defaultValue: $defaultValue)',
        );
        nextFieldId++;
      } else {
        yield Replacement.forNode(
          annotation,
          '@TapeField($fieldId, defaultValue: $defaultValue)',
        );
      }
    }

    /// Update the `@TapeClass` annotation.
    if (tapeClassAnnotation.nextFieldId == null) {
      /// It doesn't contain a `nextFieldId` field yet.
      /// Finish the @TapeClass annotation.
      yield Replacement.forNode(
        tapeClassAnnotation,
        '@TapeClass(nextFieldId: $nextFieldId)',
      );
    }
  }

  Iterable<Replacement> _ensurePartOfDirectiveExists(
    CompilationUnit unit,
  ) sync* {
    final generatedFileName = '$nameWithoutExtension.g.dart';

    // Make sure a `part 'some_file.g.dart';` directive exists.
    final hasDirective = unit.directives
        .whereType<PartDirective>()
        .any((part) => part.uri.stringValue == generatedFileName);
    if (!hasDirective) {
      final offset = unit.declarations.first.offset;

      yield Replacement(
        offset: offset,
        length: 0,
        replaceWith: "part '$generatedFileName';\n\n",
      );
    }
  }
}

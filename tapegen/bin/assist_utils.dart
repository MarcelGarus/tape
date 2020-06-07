import 'package:analyzer/dart/ast/ast.dart';
import 'package:dartx/dartx.dart';

const freezedName = 'freezed';
const tapeClassName = 'TapeClass';
const tapeFieldName = 'TapeField';
const doNotTapeName = 'doNotTape';
const nextFieldIdName = 'nextFieldId';
const defaultValueName = 'defaultValue';

extension FancyAnnotation on Annotation {
  bool get hasArgument => (arguments?.length ?? 0) > 0;

  // @TapeClass(nextFieldId: 2)
  int get nextFieldId => (arguments?.arguments ?? [])
      .whereType<NamedExpression>()
      .singleWhere((arg) => arg.name.label.toSource() == nextFieldIdName,
          orElse: () => null)
      ?.expression
      ?.unParenthesized
      ?.toSource()
      ?.toIntOrNull();

  // @TapeField(4, defaultValue: 'foo')
  int get fieldId =>
      arguments?.arguments?.firstOrNull?.toSource()?.toIntOrNull();
  String get defaultValue => (arguments?.arguments ?? [])
      .whereType<NamedExpression>()
      .singleWhere((arg) => arg.name.label.toSource() == defaultValueName,
          orElse: () => null)
      ?.expression
      ?.unParenthesized
      ?.toSource();
}

extension NamedAnnotations on List<Annotation> {
  Iterable<Annotation> withName(String name) =>
      where((annotation) => annotation.name.name == name);
}

/// We want to be able to get the annotations of [ClassDeclaration]s,
/// [FieldElement]s (class fields), and [FormalParameter]s (constructor
/// parameters).
/// However, not all of them implement [AnnotatedNode]. Apparently,
/// [AnnotatedNode] also implies that the class supports doc-comments.
/// [FormalParameter]s don't, so we implement our own [annotations] getter on
/// [AstNode]s that will give us annotations in all those cases.
extension AnnotatedAstNode on AstNode {
  List<Annotation> get annotations {
    // try-catch suggested by @jakemac53
    try {
      return (this as dynamic).metadata;
    } on NoSuchMethodError {
      return [];
    }
  }

  // @freezed
  bool get isFreezed => annotations.withName(freezedName).isNotEmpty;

  // @TapeClass
  Annotation get tapeClassAnnotation =>
      annotations.withName(tapeClassName).firstOrNull;
  bool get isTapeClass => tapeClassAnnotation != null;

  // @TapeField
  Annotation get tapeFieldAnnotation =>
      annotations.withName(tapeFieldName).firstOrNull;
  bool get isTapeField => tapeFieldAnnotation != null;

  // @doNotTape
  Annotation get doNotTapeAnnotation =>
      annotations.withName(doNotTapeName).firstOrNull;
  bool get doNotTape => doNotTapeAnnotation != null;
}

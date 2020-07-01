import 'package:analyzer/dart/ast/ast.dart';
import 'package:dartx/dartx.dart';

import 'utils.dart';

export 'package:analyzer/dart/ast/ast.dart';

// Annotation names from the freezed package.
const freezedName = 'freezed';
const freezedDefaultName = 'Default';

// Annotation names from the tape package.
const tapeInitializationName = 'TapeInitialization';
const nextTypeIdName = 'nextTypeId';
const tapeClassName = 'TapeClass';
const tapeFieldName = 'TapeField';
const doNotTapeName = 'doNotTape';
const nextFieldIdName = 'nextFieldId';
const defaultValueName = 'defaultValue';

extension FancyAnnotation on Annotation {
  bool get hasArgument => (arguments?.length ?? 0) > 0;

  // @Default(value)
  String get freezedDefaultValue => (arguments?.arguments ?? <Expression>[])
      .firstOrNull
      ?.unParenthesized
      ?.toSource();

  // @TapeInitialization(nextTypeId: 2)
  int get nextTypeId => (arguments?.arguments ?? [])
      .whereType<NamedExpression>()
      .where((arg) => arg.name.label.toSource() == nextTypeIdName)
      .singleOrNull
      ?.expression
      ?.unParenthesized
      ?.toSource()
      ?.toIntOrNull();

  // @TapeClass(nextFieldId: 2)
  int get nextFieldId => (arguments?.arguments ?? [])
      .whereType<NamedExpression>()
      .where((arg) => arg.name.label.toSource() == nextFieldIdName)
      .singleOrNull
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
/// `FieldElement`s (class fields), and [FormalParameter]s (constructor
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
      // Catching errors is fine in this case, because the API is badly
      // designed.
      // ignore: avoid_catching_errors
    } on NoSuchMethodError {
      return [];
    }
  }

  // @freezed
  bool get isFreezed => annotations.withName(freezedName).isNotEmpty;

  // @Default(value).
  Annotation get freezedDefaultAnnotation =>
      annotations.withName(freezedDefaultName).firstOrNull;
  bool get hasFreezedDefault => freezedDefaultAnnotation != null;

  // @TapeInitialization
  Annotation get tapeInitializationAnnotation =>
      annotations.withName(tapeInitializationName).firstOrNull;
  bool get isTapeInitialization => tapeInitializationAnnotation != null;

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

extension FancyCompilationUnit on CompilationUnit {
  Iterable<ImportDirective> get imports =>
      directives?.whereType<ImportDirective>() ?? [];

  Iterable<FunctionDeclaration> get topLevelFunctions =>
      declarations?.whereType<FunctionDeclaration>() ?? [];
}

extension MainFunctionFinder on Iterable<FunctionDeclaration> {
  FunctionDeclaration withName(String name) =>
      firstOrNullWhere((function) => function.name.toSource() == name);
  FunctionDeclaration get mainFunction => withName('main');
}

extension FunctionBodyGetter on FunctionDeclaration {
  FunctionBody get body => functionExpression.body;
  Block get bodyBlock => body?.as<BlockFunctionBody>()?.block;
}

extension FancyStatements on Iterable<Statement> {
  Iterable<Expression> get allExpressions => whereType<ExpressionStatement>()
      ?.map((statement) => statement.expression);
}

extension SpecificMethodInvocation on Iterable<MethodInvocation> {
  Iterable<MethodInvocation> withName(String name) =>
      where((invocation) => invocation.methodName.toSource() == name);
}

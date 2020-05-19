import 'package:analyzer/dart/ast/ast.dart';
import 'package:dartx/dartx.dart';

extension NamedAnnotations on List<Annotation> {
  Iterable<Annotation> withName(String name) =>
      where((annotation) => annotation.name.name == name);
}

extension _NumberArgument on Annotation {
  int get firstArgAsInt =>
      arguments?.arguments?.firstOrNull?.toSource()?.toIntOrNull();
}

extension AnnotationOfClass on ClassDeclaration {
  Annotation get tapeClassAnnotation =>
      metadata.withName('TapeClass').firstOrNull;
  bool get isTapeClass => tapeClassAnnotation != null;
  int get nextFieldId => tapeClassAnnotation?.firstArgAsInt;
}

extension AnnotationOfField on FieldDeclaration {
  Annotation get tapeFieldAnnotation =>
      metadata.withName('TapeField').firstOrNull;
  Annotation get doNotTapeAnnotation =>
      metadata.withName('DoNotTape').firstOrNull;
  bool get isTapeField => tapeFieldAnnotation != null;
  bool get doNotTape => doNotTapeAnnotation != null;
  int get fieldId => tapeFieldAnnotation?.firstArgAsInt;
}

extension ClassesWithAnnotation on Iterable<ClassDeclaration> {
  Iterable<ClassDeclaration> withAnnotation(String name) =>
      where((declaration) => declaration.metadata.withName(name).isNotEmpty);
}

extension FieldsWithAnnotation on Iterable<FieldDeclaration> {
  Iterable<FieldDeclaration> withAnnotation(String name) =>
      where((declaration) => declaration.metadata.withName(name).isNotEmpty);
}

extension HasArgument on Annotation {
  bool get hasArgument => (arguments?.length ?? 0) > 0;
}

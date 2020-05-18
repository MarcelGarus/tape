import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:tape/tape.dart';

final tapeTypeChecker = TypeChecker.fromRuntime(TapeType);
final tapeClassChecker = TypeChecker.fromRuntime(TapeClass);
final tapeFieldChecker = TypeChecker.fromRuntime(TapeField);

extension IsTapeField on FieldElement {
  bool get isTapeField {
    return tapeFieldChecker.hasAnnotationOf(this, throwOnUnresolved: false);
  }
}

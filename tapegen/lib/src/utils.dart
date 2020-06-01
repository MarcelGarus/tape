import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:tape/tape.dart';

final tapeTypeChecker = TypeChecker.fromRuntime(TapeType);
final tapeClassChecker = TypeChecker.fromRuntime(TapeClass);
final tapeFieldChecker = TypeChecker.fromRuntime(TapeField);
final doNotTapeChecker = TypeChecker.fromRuntime(DoNotTapeImpl);

extension IsTapeType on Element {
  bool get isTapeType {
    return tapeTypeChecker.hasAnnotationOf(this, throwOnUnresolved: false);
  }

  bool get isNotTapeType => !isTapeType;

  String get trackingCode {
    final field = tapeTypeChecker
        .firstAnnotationOf(this, throwOnUnresolved: false)
        ?.getField('trackingCode');
    return (field?.isNull ?? true) ? null : field.toStringValue();
  }

  bool get hasTrackingCode => trackingCode != null;
  bool get hasNoTrackingCode => !hasTrackingCode;

  bool get isTapeClass {
    return tapeClassChecker.hasAnnotationOf(this, throwOnUnresolved: false);
  }

  bool get isTapeField {
    return tapeFieldChecker.hasAnnotationOf(this, throwOnUnresolved: false);
  }

  int get fieldId {
    final field = tapeFieldChecker
        .firstAnnotationOf(this, throwOnUnresolved: false)
        .getField('id');
    return field.isNull ? null : field.toIntValue();
  }
}

extension InitializingFormalParameters on ConstructorElement {
  Iterable<ParameterElement> get initializingFormalParameters =>
      parameters.where((param) => param.isInitializingFormal);
}

extension FancyClass on ClassElement {
  String get nameWithGenerics =>
      thisType.getDisplayString(withNullability: false);
  String get nameWithoutGenerics => name;

  List<FieldElement> get fieldsToTape =>
      fields.where((field) => field.isTapeField).toList();
}

extension CruftRemover on String {
  /// Some code generation libraries add some cruft to class names to make a
  /// name collision less likely. This leads to ugly names like `_$Name` though.
  /// So here we remove that cruft.
  String get withoutCruft => replaceAll(RegExp(r'_|\$'), '');
}

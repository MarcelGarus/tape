part of 'type_registry.dart';

typedef Writer<T> = void Function(TapeWriter writer, T obj);
typedef Reader<T> = T Function(TapeReader reader);
typedef SubTypeAdapterBuilder<T> = AdapterFor<T> Function();

/// [AdapterFor]s can be implemented to support serializing and deserializing
/// Dart objects of type [T].
@immutable
abstract class AdapterFor<T> {
  const AdapterFor();

  Type get type => T;

  void write(TapeWriter writer, T obj);
  T read(TapeReader reader);

  /// Registers this adapter for the given [typeId].
  void registerForId(
    int typeId, {
    bool showWarningForSubtypes = true,
  }) =>
      _registerForId(typeId, TypeRegistry,
          showWarningForSubtypes: showWarningForSubtypes);

  /// Registers this adapter for the given [typeId] on the given [registry].
  void _registerForId(
    int typeId,
    TypeRegistryImpl registry, {
    @required bool showWarningForSubtypes,
  }) =>
      registry.registerAdapter<T>(
        typeId,
        this,
        showWarningForSubtypes: showWarningForSubtypes,
      );

  /// [AdapterFor]s should have no internal state/fields whatsoever.
  /// To clients, they should be merely a wrapper class around the [write] and
  /// [read] method. That's why if you create two adapters of the same type,
  /// they should be equal. We explicitly encode that here so that users don't
  /// get weird errors if they try to register the "same" adapter twice:
  ///
  /// ```dart
  /// AdapterForSomething().registerForId(0);
  /// AdapterForSomething().registerForId(0); // Should not throw an error.
  /// ```
  bool operator ==(Object other) {
    return runtimeType == other.runtimeType;
  }

  String toString() => runtimeType.toString();
}

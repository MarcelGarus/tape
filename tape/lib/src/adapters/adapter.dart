import 'dart:math';

import 'package:meta/meta.dart';

import '../blocks/blocks.dart';
import 'errors.dart';

part 'registry.dart';

@immutable
abstract class TapeAdapter<T> {
  const TapeAdapter();

  Type get type => T;

  /// Registers this adapter for the given [typeId] on the given [registry].
  void _registerForId(
    int typeId, {
    _TapeRegistryImpl registry,
    bool showWarningForSubtypes = true,
  }) {
    (registry ?? TapeRegistry).registerAdapter<T>(typeId, this,
        showWarningForSubtypes: showWarningForSubtypes);
  }

  Block toBlock(T object);
  T fromBlock(Block block);
}

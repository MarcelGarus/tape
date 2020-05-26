import 'dart:math';

import 'package:meta/meta.dart';

import 'built_in/built_in.dart';
import 'errors.dart';

part 'tape_registry.dart';

abstract class TapeAdapter<T, CorrespondingBlock> {
  const TapeAdapter();

  Type get type => T;

  /// Registers this adapter for the given [typeId] on the given [registry].
  void _registerForId(
    int typeId, {
    TapeRegistryImpl registry,
    bool showWarningForSubtypes = true,
  }) {
    (registry ?? TapeRegistry).registerAdapter<T>(typeId, this,
        showWarningForSubtypes: showWarningForSubtypes);
  }

  CorrespondingBlock toBlock(T object);
  T fromBlock(CorrespondingBlock block);
}

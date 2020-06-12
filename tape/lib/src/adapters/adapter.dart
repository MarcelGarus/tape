import 'package:meta/meta.dart';

import '../blocks/blocks.dart';
import 'registry.dart';

@immutable
abstract class TapeAdapter<T> {
  const TapeAdapter();

  Type get type => T;

  /// Registers this adapter for the given [typeId] on the given [registry].
  void registerForId({
    @required int typeId,
    @required TapeRegistry registry,
    bool showWarningForSubtypes = true,
  }) {
    (registry ?? defaultTapeRegistry).registerAdapter<T>(typeId, this,
        showWarningForSubtypes: showWarningForSubtypes);
  }

  Block toBlock(T object);
  T fromBlock(Block block);
}

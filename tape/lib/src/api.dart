import 'adapters/adapters.dart';
import 'built_in/built_in.dart';

/// Adapters get registered here and packages provide initializing extension
/// methods on this object.
final Tape = TapeApi._default();

/// Next to the [tape] codec, the [TapeApi] is the main way to interact with
/// tape. For now, that's only registering adapters.
/// To counter confusion, the [TapeApi]'s `registerAdapters` method ensures that
/// all ids are non-negative if imported via `package:tape/tape.dart`, or that
/// all ids are negative if imported via `package:tape/package.dart`. To
/// accomplish that, `registerAdapters` is defined as two extension methods, one
/// of which is exported in `tape.dart`, and the other in `package.dart`,
/// respectively.
class TapeApi {
  TapeApi._default() : this._withRegistry(defaultTapeRegistry);
  TapeApi._withRegistry(this._registry) {
    registerBuiltInAdapters(_registry);
  }

  final TapeRegistry _registry;

  TapeApi get instance => TapeApi._withRegistry(TapeRegistry());

  void registerVirtualNode<T>() => _registry.registerVirtualNode<T>();
}

extension RegisterAdapters on TapeApi {
  void registerAdapters(
    Map<int, TapeAdapter<dynamic>> adaptersById, {
    bool showWarningForSubtypes = true,
  }) {
    assert(adaptersById.keys.every((id) => id >= 0));
    _registry.registerAdapters(adaptersById,
        showWarningForSubtypes: showWarningForSubtypes);
  }
}

extension RegisterPackageAdapters on TapeApi {
  void registerAdapters(
    Map<int, TapeAdapter<dynamic>> adaptersById, {
    bool showWarningForSubtypes = true,
  }) {
    assert(adaptersById.keys.every((id) => id < 0));
    _registry.registerAdapters(adaptersById,
        showWarningForSubtypes: showWarningForSubtypes);
  }
}

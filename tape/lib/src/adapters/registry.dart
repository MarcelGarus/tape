import 'dart:math';

import 'package:meta/meta.dart';

import 'adapter.dart';
import 'errors.dart';
import 'utils.dart';

void debugPrint(Object object) {
  // ignore: avoid_print
  if (isDebugMode) print(object);
}

/// The [defaultTapeRegistry] holds references to all [TapeAdapter]s used to
/// serialize and deserialize classes. It the registry makes it possible to
/// - get an adapter for a specific object,
/// - get an adapter by its id, and
/// - get the id of an adapter.
final defaultTapeRegistry = TapeRegistry();

class TapeRegistry {
  TapeRegistry();

  // For greater efficiency, there are several data structures that hold
  // references to adapters. These allow us to:
  // - Get the id of an adapter in O(1).
  // - Get an adapter for an id in O(1).
  // - If the static type of an object equals its runtime type, getting the
  //   correct adapter for that object in O(1).
  // - If the static type of an object differs from its runtime type, getting
  //   the correct adapter somewhere between O(log n) and O(n), depending on
  //   the class hierarchy.
  final _idsByAdapters = <TapeAdapter<dynamic>, int>{};
  final _adaptersByIds = <int, TapeAdapter<dynamic>>{};
  final _adapterTree = _AdapterNode<Object>.virtual();
  final _nodesByTypes = <Type, _AdapterNode<dynamic>>{};

  /// If an exact type can't be encoded, we suggest adding an adapter. Here, we
  /// keep track of which adapters we suggested along with the suggested id.
  final _suggestedAdapters = <String, int>{};

  /// Registers a virtual [_AdapterNode].
  void registerVirtualNode<T>() {
    final node = _AdapterNode<T>.virtual();

    _nodesByTypes[T] ??= node;
    _adapterTree.insert(node);
  }

  /// Registers a [AdapterFor<T>] to make it available for serializing and
  /// deserializing.
  void registerAdapter<T>(
    int typeId,
    TapeAdapter<T> adapter, {
    bool showWarningForSubtypes = true,
  }) {
    assert(typeId != null);
    assert(adapter != null);
    assert(showWarningForSubtypes != null);

    var isDebug = false;
    assert(isDebug = true);
    if (isDebug) {
      if (_idsByAdapters.containsKey(adapter)) {
        final previousId = _idsByAdapters[adapter];
        if (previousId == typeId) {
          throw AdapterAlreadyRegisteredError(adapter: adapter, id: typeId);
        } else {
          throw AdapterAlreadyRegisteredForDifferentIdError(
            adapter: adapter,
            firstId: _idsByAdapters[adapter],
            secondId: typeId,
          );
        }
      }

      final adapterForId = _adaptersByIds[typeId];
      if (adapterForId != null && adapterForId != adapter) {
        throw IdAlreadyInUseError(
          adapter: adapter,
          id: typeId,
          adapterForId: adapterForId,
        );
      }
    }

    _idsByAdapters[adapter] = typeId;
    _adaptersByIds[typeId] = adapter;

    final node = _AdapterNode<T>(
      adapter: adapter,
      showWarningForSubtypes: showWarningForSubtypes,
    );

    _nodesByTypes[adapter.type] ??= node;
    _adapterTree.insert(node);
  }

  /// Register multiple adapters.
  void registerAdapters(
    Map<int, TapeAdapter<dynamic>> adaptersById, {
    bool showWarningForSubtypes = true,
  }) {
    // We don't directly call [registerAdapter], but rather let the adapter
    // call that method, because otherwise we would lose type information (the
    // static type of the adapters inside the map is `TypeAdapter<dynamic>`).
    adaptersById.forEach((typeId, adapter) {
      adapter.registerForId(
        typeId: typeId,
        registry: this,
        showWarningForSubtypes: showWarningForSubtypes,
      );
    });
  }

  /// Finds the id of an adapter.
  int idOfAdapter(TapeAdapter<dynamic> adapter) => _idsByAdapters[adapter];

  /// Finds the adapter registered for the given [typeId].
  TapeAdapter<dynamic> adapterForId(int typeId) => _adaptersByIds[typeId];

  /// Finds an adapter for serializing the [object].
  TapeAdapter<T> adapterByValue<T>(T object) {
    // Find the best matching adapter in the type tree.
    final searchStartNode = _nodesByTypes[object.runtimeType] ?? _adapterTree;
    final matchingNode = searchStartNode.findNodeByValue(object);
    final matchingType = matchingNode.type;
    final actualType = object.runtimeType;

    if (matchingNode.adapter == null) {
      throw Exception('No adapter for the type $actualType found. Consider '
          'adding an adapter for that type by calling '
          '${_createAdapterSuggestion(actualType)}.');
    }

    if (matchingNode.showWarningForSubtypes &&
        !_debugIsSameType(actualType, matchingType)) {
      debugPrint('No adapter for the exact type $actualType found, so we\'re '
          'encoding it as a ${matchingNode.type}. For better performance and '
          'truly type-safe serializing, consider adding an adapter for that '
          'type by calling ${_createAdapterSuggestion(actualType)}.');
    }

    return matchingNode.adapter;
  }

  static bool _debugIsSameType(Type runtimeType, Type staticType) {
    return staticType.toString() ==
        runtimeType
            .toString()
            .replaceAll('JSArray', 'List')
            .replaceAll('_CompactLinkedHashSet', 'Set')
            .replaceAll('_InternalLinkedHashMap', 'Map');
  }

  String _createAdapterSuggestion(Type type) {
    final suggestedId = _suggestedAdapters[type.toString()] ??
        (_adaptersByIds.isEmpty
            ? 0
            : _adaptersByIds.keys.reduce(max) + 1 + _suggestedAdapters.length);
    _suggestedAdapters[type.toString()] = suggestedId;

    return 'AdapterFor$type().registerForId($suggestedId)';
  }

  void debugDumpTree() => _adapterTree.debugDump();
}

/// We maintain a tree of `_AdapterNode`s for cases where resolving adapter's by
/// an object's runtime type doesn't work.
///
/// - An adapter might be able to encode a `SampleClass` and all its
///   subclasses, so there don't need to be adapters for the subclasses.
/// - Some types cannot be known statically. For example, `<int>[].runtimeType`
///   is not the same `List<int>` as a static `List<int>`. At runtime, it's
///   either a (different) `List<int>` or a `JSArray` (if running on the web).
///
/// That being said, there exist shortcuts into the tree based on the runtime
/// type that are preferred over traversing the tree.
class _AdapterNode<T> {
  _AdapterNode({
    @required this.adapter,
    this.showWarningForSubtypes = true,
  }) : assert(showWarningForSubtypes != null);

  _AdapterNode.virtual() : this(adapter: null);

  /// The adapter registered for this type node.
  final TapeAdapter<T> adapter;
  bool get isVirtual => adapter == null;

  /// Whether to show warnings for subtypes. If `true` and values do not match
  /// this [_AdapterNode] exactly, a warning will be outputted to the console.
  /// For example, if the developer tries to encode a `SomeType<int>`, but the
  /// only [_AdapterNode] found is one of `SomeType<dynamic>`, a warning will be
  /// logged in the console if [showWarningForSubtypes] is `true`.
  final bool showWarningForSubtypes;

  /// [_AdapterNode]s of subtypes.
  final _children = <_AdapterNode<T>>{};

  Type get type => T;

  bool matches(dynamic value) => value is T;

  bool isSupertypeOf(_AdapterNode<dynamic> node) {
    return node is _AdapterNode<T>;
  }

  void addNode(_AdapterNode<T> type) => _children.add(type);
  void addSubNodes(Iterable<_AdapterNode<dynamic>> types) =>
      _children.addAll(types.cast<_AdapterNode<T>>());

  void insert(_AdapterNode<T> newNode) {
    final parentNodes = _children.where((type) => type.isSupertypeOf(newNode));

    if (parentNodes.isNotEmpty) {
      for (final subtype in parentNodes) {
        subtype.insert(newNode);
      }
    } else {
      final typesUnderNewType = _children.where(newNode.isSupertypeOf).toList();
      _children.removeAll(typesUnderNewType);
      newNode.addSubNodes(typesUnderNewType);
      _children.add(newNode);
    }
  }

  _AdapterNode<T> findNodeByValue(T value) {
    final matchingSubNode = _children.firstWhere(
      (type) => type.matches(value),
      orElse: () => null,
    );
    return matchingSubNode?.findNodeByValue(value) ?? this;
  }

  void debugDump() {
    final buffer = StringBuffer()
      ..writeln('root node for objects to serialize');
    final children = _children;

    for (final child in children) {
      buffer.write(child._debugToString('', child == children.last));
    }
    debugPrint(buffer);
  }

  String _debugToString(String prefix, bool isLast) {
    final children = _children.toList();
    return [
      prefix,
      if (isVirtual)
        '${isLast ? '└─' : '├─'} virtual node for $type'
      else
        '${isLast ? '└─' : '├─'} ${adapter.runtimeType}',
      '\n',
      for (final child in children)
        child._debugToString(
            '$prefix${isLast ? '   ' : '│  '}', child == children.last),
    ].join();
  }
}

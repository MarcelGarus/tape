/// Adapters for types from `dart:core`.

part of 'built_in.dart';

/// Adapter that `List`s as a `ListBlock`s.
@immutable
class AdapterForList<T> extends TapeAdapter<List<T>, ListBlock> {
  const AdapterForList();

  @override
  List<T> fromBlock(ListBlock block) {
    return <T>[for (final item in block.items) _decode(item)];
  }

  @override
  ListBlock toBlock(List<T> list) {
    return ListBlock(list.map(_encode).toList());
  }
}

/// Adapter that encodes `Set`s as `ListBlock`s.
class AdapterForSet<T> extends TapeAdapter<Set<T>, ListBlock> {
  const AdapterForSet();

  @override
  Set<T> fromBlock(ListBlock block) {
    return <T>{for (final item in block.items) _decode(item)};
  }

  @override
  ListBlock toBlock(Set<T> set) {
    return ListBlock(set.map(_encode).toList());
  }
}

/// Adapter that encodes `MapEntry`s as classes.
class AdapterForMapEntry<K, V> extends TapeClassAdapter<MapEntry<K, V>> {
  const AdapterForMapEntry();

  @override
  MapEntry<K, V> fromFields(Fields fields) {
    return MapEntry(
      fields.get(0, orDefault: null),
      fields.get(1, orDefault: null),
    );
  }

  @override
  Fields toFields(MapEntry<K, V> entry) {
    return Fields({
      0: entry.key,
      1: entry.value,
    });
  }
}

/// Adapter that encodes `Map`s as lists of encoded `MapEntry`s.
class AdapterForMap<K, V> extends TapeAdapter<Map<K, V>, ListBlock> {
  const AdapterForMap();

  @override
  Map<K, V> fromBlock(ListBlock block) {
    final entryAdapter = AdapterForMapEntry<K, V>();
    final entries = {
      for (final item in block.items) entryAdapter.fromBlock(item)
    };
    return Map<K, V>.fromEntries(entries);
  }

  @override
  ListBlock toBlock(Map<K, V> map) {
    final entryAdapter = AdapterForMapEntry<K, V>();
    return ListBlock([
      for (final entry in map.entries) entryAdapter.toBlock(entry),
    ]);
  }
}

class AdapterForBigInt extends TapeAdapter<BigInt, BytesBlock> {
  const AdapterForBigInt();

  @override
  void write(TapeWriter writer, BigInt value) {
    final bits = <bool>[value.isNegative];
    value = value.abs();

    while (value > BigInt.zero) {
      bits.add(value % BigInt.two == BigInt.one);
      value ~/= BigInt.two;
    }

    const AdapterForList<bool>().write(writer, bits);
  }

  @override
  BigInt read(TapeReader reader) {
    final bits = const AdapterForList<bool>().read(reader);
    final isNegative = bits.removeAt(0);

    var value = BigInt.zero;
    while (bits.isNotEmpty) {
      value *= BigInt.two;
      value += bits.removeAt(0) ? BigInt.one : BigInt.zero;
    }

    return value * (isNegative ? BigInt.from(-1) : BigInt.one);
  }

  @override
  BigInt fromBlock(BytesBlock block) {
    // TODO: implement fromBlock
    return null;
  }

  @override
  BytesBlock toBlock(BigInt object) {
    // TODO: implement toBlock
    return null;
  }
}

/// Adapter for a `DateTime`.
class AdapterForDateTime extends TapeAdapter<DateTime> {
  const AdapterForDateTime();

  @override
  void write(TapeWriter writer, DateTime value) =>
      const AdapterForInt().write(writer, value.microsecondsSinceEpoch);

  @override
  DateTime read(TapeReader reader) =>
      DateTime.fromMicrosecondsSinceEpoch(const AdapterForInt().read(reader));
}

/// Adapter for a `Duration`. Encoded as the number of microseconds.
class AdapterForDuration extends TapeAdapter<Duration> {
  const AdapterForDuration();

  @override
  void write(TapeWriter writer, Duration value) =>
      const AdapterForInt().write(writer, value.inMicroseconds);

  @override
  Duration read(TapeReader reader) =>
      Duration(microseconds: const AdapterForInt().read(reader));
}

/// Adapter for a `RegExp`.
class AdapterForRegExp extends TapeAdapter<RegExp> {
  const AdapterForRegExp();

  @override
  void write(TapeWriter writer, RegExp regExp) {
    assert(!regExp.pattern.contains('\0'));
    const AdapterForString().write(writer, regExp.pattern);
    const AdapterForList<bool>().write(writer, <bool>[
      regExp.isCaseSensitive,
      regExp.isMultiLine,
      regExp.isUnicode,
      regExp.isDotAll,
    ]);
  }

  @override
  RegExp read(TapeReader reader) {
    final pattern = const AdapterForString().read(reader);
    final bools = const AdapterForList<bool>().read(reader);

    return RegExp(
      pattern,
      caseSensitive: bools[0],
      multiLine: bools[1],
      unicode: bools[2],
      dotAll: bools[3],
    );
  }
}

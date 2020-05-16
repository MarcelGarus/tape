/// Adapters for types from `dart:core`.

part of 'adapters.dart';

/// Adapter for `Null`s.
///
/// Because instances of type `Null` can only have one value (`null`), we don't
/// actually need to encode any bytes at all.
///
/// Example: `null`
/// Encoded: -
class AdapterForNull extends AdapterFor<Null> {
  const AdapterForNull();

  @override
  void write(_, __) {}

  @override
  Null read(_) => null;
}

/// Adapter for `double`s.
///
/// Encodes a `double` as a float64.
///
/// Example: 2.0
/// Encoded: TODO
class AdapterForDouble extends AdapterFor<double> {
  const AdapterForDouble();

  @override
  void write(TapeWriter writer, double value) => writer.writeFloat64(value);

  @override
  double read(TapeReader reader) => reader.readFloat64();
}

/// Adapter for `int`s.
///
/// In the native Dart VM, `int`s are encoded as 64-bit signed integers. That's
/// why this adapter also encodes an `int` that way.
///
/// Example: 6
/// Encoded: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000110
class AdapterForInt extends AdapterFor<int> {
  const AdapterForInt();

  @override
  void write(TapeWriter writer, int value) => writer.writeInt64(value);

  @override
  int read(TapeReader reader) => reader.readInt64();
}

/// Adapter for `bool`s.
///
/// Encodes a `bool` as a single byte that is either 1 for true or 0 for false.
///
/// Example: `true`
/// Encoded: 00000001
class AdapterForBool extends AdapterFor<bool> {
  const AdapterForBool();

  @override
  void write(TapeWriter writer, bool value) => writer.writeUint8(value ? 1 : 0);

  @override
  bool read(TapeReader reader) => reader.readUint8() == 1;
}

/// Adapter for `String`s.
///
/// Encodes a `String` as the length as a uint32 followed by the UTF8-encoded
/// string bytes.
///
/// Example: `"foo"`
/// Encoded: 00000000 00000000 00000000 00000011 TODO
///           ------------- length -------------- --------- content ----
class AdapterForString extends AdapterFor<String> {
  const AdapterForString();

  @override
  void write(TapeWriter writer, String value) {
    final bytes = utf8.encode(value);
    writer.writeUint32(bytes.length);
    for (final byte in bytes) {
      writer.writeUint8(byte);
    }
  }

  @override
  String read(TapeReader reader) {
    final numBytes = reader.readUint32();
    final bytes = <int>[
      for (int i = 0; i < numBytes; i++) reader.readUint8(),
    ];
    return utf8.decode(bytes);
  }
}

/// Adapter for `List`s.
///
/// Because the list's elements may have subclasses, the type has to be encoded
/// for every element. That means, we call `writer.write` on each element.
/// Encodes a `List` as the length of the list and then encoding each element
/// along with separate type information.
///
/// Example: `[true, true, false]`
/// Encoded:
class AdapterForList<T> extends AdapterFor<List<T>> {
  const AdapterForList();

  @override
  void write(TapeWriter writer, List<T> list) {
    writer.writeUint32(list.length);
    list.forEach(writer.write);
  }

  @override
  List<T> read(TapeReader reader) {
    final length = reader.readUint32();
    return <T>[
      for (var i = 0; i < length; i++) reader.read<T>(),
    ];
  }
}

/// Adapter that encodes a [Set<T>] by just delegating the responsibility to an
/// [AdapterForList<T>].
class AdapterForSet<T> extends AdapterFor<Set<T>> {
  const AdapterForSet();

  @override
  void write(TapeWriter writer, Set<T> theSet) => writer.write(theSet.toList());

  @override
  Set<T> read(TapeReader reader) => reader.read<List<T>>().toSet();
}

class AdapterForMapEntry<K, V> extends AdapterFor<MapEntry<K, V>> {
  const AdapterForMapEntry();

  @override
  void write(TapeWriter writer, MapEntry<K, V> entry) =>
      writer..write(entry.key)..write(entry.value);

  @override
  MapEntry<K, V> read(TapeReader reader) =>
      MapEntry(reader.read<K>(), reader.read<V>());
}

class AdapterForMap<K, V> extends AdapterFor<Map<K, V>> {
  const AdapterForMap();

  @override
  void write(TapeWriter writer, Map<K, V> map) {
    final entries = map.entries.toList();
    final keys = entries.map((entry) => entry.key).toList();
    final values = entries.map((entry) => entry.value).toList();
    writer..write(keys)..write(values);
  }

  @override
  Map<K, V> read(TapeReader reader) {
    final keys = reader.read<List<K>>();
    final values = reader.read<List<V>>();
    return {
      for (var i = 0; i < keys.length; i++) keys[i]: values[i],
    };
  }
}

class AdapterForBigInt extends AdapterFor<BigInt> {
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
}

/// Adapter for a `DateTime`.
class AdapterForDateTime extends AdapterFor<DateTime> {
  const AdapterForDateTime();

  @override
  void write(TapeWriter writer, DateTime value) =>
      const AdapterForInt().write(writer, value.microsecondsSinceEpoch);

  @override
  DateTime read(TapeReader reader) =>
      DateTime.fromMicrosecondsSinceEpoch(const AdapterForInt().read(reader));
}

/// Adapter for a `Duration`. Encoded as the number of microseconds.
class AdapterForDuration extends AdapterFor<Duration> {
  const AdapterForDuration();

  @override
  void write(TapeWriter writer, Duration value) =>
      const AdapterForInt().write(writer, value.inMicroseconds);

  @override
  Duration read(TapeReader reader) =>
      Duration(microseconds: const AdapterForInt().read(reader));
}

/// Adapter for a `RegExp`.
class AdapterForRegExp extends AdapterFor<RegExp> {
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

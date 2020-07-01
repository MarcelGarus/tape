/// Adapters for types from `dart:core`.

import 'dart:convert';

import '../../package.dart';
import 'built_in.dart';

extension DartCoreTaped on TapeApi {
  void registerDartCoreAdapters() {
    // Virtual nodes for more efficiency.
    registerVirtualNode<Iterable<dynamic>>();
    registerVirtualNode<num>();

    // Primitive types.
    registerAdapters({
      -1: AdapterForNull(),
      -2: AdapterForBool(),
      -3: AdapterForString(),
      -4: AdapterForUint8(),
      -5: AdapterForUint16(),
      -6: AdapterForUint32(),
      -7: AdapterForInt8(),
      -8: AdapterForInt16(),
      -9: AdapterForInt32(),
      -10: AdapterForInt(),
      -11: AdapterForFloat32(),
      -12: AdapterForDouble(),
      -13: AdapterForBigInt(),
      -14: AdapterForDateTime(),
      -15: AdapterForDuration(),
      -16: AdapterForRegExp(),
    });

    // For collection types, we don't want a combinatorial explosion, while
    // still defining some commonly-used adapters. For example, `List<Null>`,
    // which could only contain a sequence of `null`, doesn't really make sense
    // and is thus omitted. On the other hand, List<String> is more common, so
    // we define an adapter for it.
    // Since `double`s are imprecise (because of rounding errors), they're
    // typically not used as map keys, so the corresponding adapters are also
    // not pre-registered here. `DateTime`s or `Duration`s are also uncommon as
    // map keys.
    registerAdapters({
      -17: AdapterForList<dynamic>(),
      -18: AdapterForList<bool>(),
      -19: AdapterForList<String>(),
      -20: AdapterForList<num>(),
      -21: AdapterForList<int>(),
      -22: AdapterForList<double>(),
      -23: AdapterForList<BigInt>(),
      -24: AdapterForList<DateTime>(),
      -25: AdapterForList<Duration>(),
    });
    registerAdapters({
      -26: AdapterForSet<dynamic>(),
      -27: AdapterForSet<bool>(),
      -28: AdapterForSet<String>(),
      -29: AdapterForSet<num>(),
      -30: AdapterForSet<int>(),
      -31: AdapterForSet<double>(),
      -32: AdapterForSet<BigInt>(),
      -33: AdapterForSet<DateTime>(),
      -34: AdapterForSet<Duration>(),
    });
    registerAdapters({
      -35: AdapterForMapEntry<dynamic, dynamic>(),
    });
    registerAdapters({
      -36: AdapterForMap<dynamic, dynamic>(),
      -37: AdapterForMap<dynamic, bool>(),
      -38: AdapterForMap<dynamic, String>(),
      -39: AdapterForMap<dynamic, num>(),
      -40: AdapterForMap<dynamic, int>(),
      -41: AdapterForMap<dynamic, double>(),
      -42: AdapterForMap<dynamic, BigInt>(),
      -43: AdapterForMap<dynamic, DateTime>(),
      -44: AdapterForMap<dynamic, Duration>(),
      -45: AdapterForMap<String, bool>(),
      -46: AdapterForMap<String, bool>(),
      -47: AdapterForMap<String, String>(),
      -48: AdapterForMap<String, num>(),
      -49: AdapterForMap<String, int>(),
      -50: AdapterForMap<String, double>(),
      -51: AdapterForMap<String, BigInt>(),
      -52: AdapterForMap<String, DateTime>(),
      -53: AdapterForMap<String, Duration>(),
      -54: AdapterForMap<int, bool>(),
      -55: AdapterForMap<int, bool>(),
      -56: AdapterForMap<int, String>(),
      -57: AdapterForMap<int, num>(),
      -58: AdapterForMap<int, int>(),
      -59: AdapterForMap<int, double>(),
      -60: AdapterForMap<int, BigInt>(),
      -61: AdapterForMap<int, DateTime>(),
      -62: AdapterForMap<int, Duration>(),
      -63: AdapterForMap<BigInt, bool>(),
      -64: AdapterForMap<BigInt, bool>(),
      -65: AdapterForMap<BigInt, String>(),
      -66: AdapterForMap<BigInt, num>(),
      -67: AdapterForMap<BigInt, int>(),
      -68: AdapterForMap<BigInt, double>(),
      -69: AdapterForMap<BigInt, BigInt>(),
      -70: AdapterForMap<BigInt, DateTime>(),
      -71: AdapterForMap<BigInt, Duration>(),
    });
  }
}

class AdapterForNull extends TapeAdapter<Null> {
  const AdapterForNull();

  @override
  Null fromBlock(Block block) => null;

  @override
  Block toBlock(Null value) => Uint8Block(0);
}

class AdapterForBool extends TapeAdapter<bool> {
  const AdapterForBool();

  @override
  bool fromBlock(Block block) => block.as<Uint8Block>().value == 1;

  @override
  Block toBlock(bool value) => Uint8Block(value ? 1 : 0);
}

class AdapterForString extends TapeAdapter<String> {
  @override
  String fromBlock(Block block) => utf8.decode(block.as<BytesBlock>().bytes);

  @override
  Block toBlock(String string) => BytesBlock(utf8.encode(string));
}

class AdapterForUint8 extends TapeAdapter<Uint8> {
  const AdapterForUint8();

  @override
  Uint8 fromBlock(Block block) => Uint8(block.as<Uint8Block>().value);

  @override
  Block toBlock(Uint8 uint8) => Uint8Block(uint8.toInt());
}

class AdapterForUint16 extends TapeAdapter<Uint16> {
  const AdapterForUint16();

  @override
  Uint16 fromBlock(Block block) => Uint16(block.as<Uint16Block>().value);

  @override
  Block toBlock(Uint16 uint16) => Uint16Block(uint16.toInt());
}

class AdapterForUint32 extends TapeAdapter<Uint32> {
  const AdapterForUint32();

  @override
  Uint32 fromBlock(Block block) => Uint32(block.as<Uint32Block>().value);

  @override
  Block toBlock(Uint32 uint32) => Uint32Block(uint32.toInt());
}

class AdapterForInt8 extends TapeAdapter<Int8> {
  const AdapterForInt8();

  @override
  Int8 fromBlock(Block block) => Int8(block.as<Int8Block>().value);

  @override
  Block toBlock(Int8 int8) => Int8Block(int8.toInt());
}

class AdapterForInt16 extends TapeAdapter<Int16> {
  const AdapterForInt16();

  @override
  Int16 fromBlock(Block block) => Int16(block.as<Int16Block>().value);

  @override
  Block toBlock(Int16 int16) => Int16Block(int16.toInt());
}

class AdapterForInt32 extends TapeAdapter<Int32> {
  const AdapterForInt32();

  @override
  Int32 fromBlock(Block block) => Int32(block.as<Int32Block>().value);

  @override
  Block toBlock(Int32 int32) => Int32Block(int32.toInt());
}

class AdapterForInt extends TapeAdapter<int> {
  const AdapterForInt();

  @override
  int fromBlock(Block block) => block.as<IntBlock>().value;

  @override
  Block toBlock(int value) => IntBlock(value);
}

class AdapterForFloat32 extends TapeAdapter<Float32> {
  const AdapterForFloat32();

  @override
  Float32 fromBlock(Block block) => Float32(block.as<Float32Block>().value);

  @override
  Block toBlock(Float32 float32) => Float32Block(float32.toDouble());
}

class AdapterForDouble extends TapeAdapter<double> {
  const AdapterForDouble();

  @override
  double fromBlock(Block block) => block.as<DoubleBlock>().value;

  @override
  Block toBlock(double value) => DoubleBlock(value);
}

class AdapterForBigInt extends TapeClassAdapter<BigInt> {
  const AdapterForBigInt();

  @override
  BigInt fromFields(Fields fields) {
    final isNegative = fields.get<bool>(0, orDefault: false);
    final bytes = fields.get<List<int>>(1);

    // From https://github.com/dart-lang/sdk/issues/32803
    BigInt read(int start, int end) {
      if (end - start <= 4) {
        int result = 0;
        for (int i = end - 1; i >= start; i--) {
          result = result * 256 + bytes[i];
        }
        return BigInt.from(result);
      }
      int mid = start + ((end - start) >> 1);
      var result = read(start, mid) +
          read(mid, end) * (BigInt.one << ((mid - start) * 8));
      return result;
    }

    final absolute = read(0, bytes.length);
    return isNegative ? -absolute : absolute;
  }

  @override
  Fields toFields(BigInt number) {
    final isNegative = number.isNegative;
    number = number.abs();

    // From https://github.com/dart-lang/sdk/issues/32803
    int numBytes = (number.bitLength + 7) >> 3;
    var b256 = BigInt.from(256);
    var bytes = Uint8List(numBytes);
    for (int i = 0; i < numBytes; i++) {
      bytes[i] = number.remainder(b256).toInt();
      number = number >> 8;
    }

    return Fields({
      0: isNegative,
      1: bytes,
    });
  }
}

class AdapterForDateTime extends TapeAdapter<DateTime> {
  const AdapterForDateTime();

  @override
  DateTime fromBlock(Block block) =>
      DateTime.fromMicrosecondsSinceEpoch(block.as<IntBlock>().value);

  @override
  Block toBlock(DateTime dateTime) => IntBlock(dateTime.microsecondsSinceEpoch);
}

class AdapterForDuration extends TapeAdapter<Duration> {
  const AdapterForDuration();

  @override
  Duration fromBlock(Block block) =>
      Duration(microseconds: block.as<IntBlock>().value);

  @override
  Block toBlock(Duration duration) => IntBlock(duration.inMicroseconds);
}

class AdapterForRegExp extends TapeClassAdapter<RegExp> {
  const AdapterForRegExp();

  @override
  RegExp fromFields(Fields fields) {
    return RegExp(
      fields.get(0),
      caseSensitive: fields.get(1, orDefault: true),
      multiLine: fields.get(2, orDefault: false),
      unicode: fields.get(3, orDefault: false),
      dotAll: fields.get(4, orDefault: false),
    );
  }

  @override
  Fields toFields(RegExp regExp) {
    return Fields({
      0: regExp.pattern,
      1: regExp.isCaseSensitive,
      2: regExp.isMultiLine,
      3: regExp.isUnicode,
      4: regExp.isDotAll,
    });
  }
}

class AdapterForList<T> extends TapeAdapter<List<T>> {
  const AdapterForList();

  @override
  List<T> fromBlock(Block block) {
    return <T>[
      for (final child in block.as<ListBlock>().children) adapters.decode(child)
    ];
  }

  @override
  ListBlock toBlock(List<T> list) =>
      ListBlock(list.map(adapters.encode).toList());
}

class AdapterForSet<T> extends TapeAdapter<Set<T>> {
  const AdapterForSet();

  @override
  Set<T> fromBlock(Block block) {
    return <T>{
      for (final child in block.as<ListBlock>().children) adapters.decode(child)
    };
  }

  @override
  ListBlock toBlock(Set<T> set) => ListBlock(set.map(adapters.encode).toList());
}

class AdapterForMapEntry<K, V> extends TapeClassAdapter<MapEntry<K, V>> {
  const AdapterForMapEntry();

  @override
  MapEntry<K, V> fromFields(Fields fields) {
    return MapEntry(fields.get(0), fields.get(1));
  }

  @override
  Fields toFields(MapEntry<K, V> entry) {
    return Fields({
      0: entry.key,
      1: entry.value,
    });
  }
}

class AdapterForMap<K, V> extends TapeAdapter<Map<K, V>> {
  const AdapterForMap();

  @override
  Map<K, V> fromBlock(Block block) {
    final entryAdapter = AdapterForMapEntry<K, V>();
    final entries = {
      for (final child in block.as<ListBlock>().children)
        entryAdapter.fromBlock(child)
    };
    return Map<K, V>.fromEntries(entries);
  }

  @override
  Block toBlock(Map<K, V> map) {
    final entryAdapter = AdapterForMapEntry<K, V>();
    return ListBlock([
      for (final entry in map.entries) entryAdapter.toBlock(entry),
    ]);
  }
}

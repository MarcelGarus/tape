// Adapters for types from `dart:core`.

import 'dart:convert';
import 'dart:typed_data';

import '../adapters/adapters.dart';
import '../blocks/blocks.dart';
import 'custom.dart';
import 'granular_types.dart';

class AdapterForNull extends TapeAdapter<Null> {
  const AdapterForNull();

  @override
  Null fromBlock(Block block) => null;

  @override
  Block toBlock(Null object) => Uint8Block(0);
}

class AdapterForBool extends TapeAdapter<bool> {
  const AdapterForBool();

  @override
  bool fromBlock(Block block) => block.as<Uint8Block>().value == 1;

  @override
  Block toBlock(bool object) => Uint8Block(object ? 1 : 0);
}

class AdapterForString extends TapeAdapter<String> {
  @override
  String fromBlock(Block block) => utf8.decode(block.as<BytesBlock>().bytes);

  @override
  Block toBlock(String object) => BytesBlock(utf8.encode(object));
}

class AdapterForUint8 extends TapeAdapter<Uint8> {
  const AdapterForUint8();

  @override
  Uint8 fromBlock(Block block) => Uint8(block.as<Uint8Block>().value);

  @override
  Block toBlock(Uint8 object) => Uint8Block(object.toInt());
}

class AdapterForUint16 extends TapeAdapter<Uint16> {
  const AdapterForUint16();

  @override
  Uint16 fromBlock(Block block) => Uint16(block.as<Uint16Block>().value);

  @override
  Block toBlock(Uint16 object) => Uint16Block(object.toInt());
}

class AdapterForUint32 extends TapeAdapter<Uint32> {
  const AdapterForUint32();

  @override
  Uint32 fromBlock(Block block) => Uint32(block.as<Uint32Block>().value);

  @override
  Block toBlock(Uint32 object) => Uint32Block(object.toInt());
}

class AdapterForInt8 extends TapeAdapter<Int8> {
  const AdapterForInt8();

  @override
  Int8 fromBlock(Block block) => Int8(block.as<Int8Block>().value);

  @override
  Block toBlock(Int8 object) => Int8Block(object.toInt());
}

class AdapterForInt16 extends TapeAdapter<Int16> {
  const AdapterForInt16();

  @override
  Int16 fromBlock(Block block) => Int16(block.as<Int16Block>().value);

  @override
  Block toBlock(Int16 object) => Int16Block(object.toInt());
}

class AdapterForInt32 extends TapeAdapter<Int32> {
  const AdapterForInt32();

  @override
  Int32 fromBlock(Block block) => Int32(block.as<Int32Block>().value);

  @override
  Block toBlock(Int32 object) => Int32Block(object.toInt());
}

class AdapterForInt extends TapeAdapter<int> {
  const AdapterForInt();

  @override
  int fromBlock(Block block) => block.as<IntBlock>().value;

  @override
  Block toBlock(int object) => IntBlock(object);
}

class AdapterForFloat32 extends TapeAdapter<Float32> {
  const AdapterForFloat32();

  @override
  Float32 fromBlock(Block block) => Float32(block.as<Float32Block>().value);

  @override
  Block toBlock(Float32 object) => Float32Block(object.toDouble());
}

class AdapterForDouble extends TapeAdapter<double> {
  const AdapterForDouble();

  @override
  double fromBlock(Block block) => block.as<DoubleBlock>().value;

  @override
  Block toBlock(double object) => DoubleBlock(object);
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
    return MapEntry(
      fields.get(0, orDefault: null), // TODO: throw
      fields.get(1, orDefault: null), // TODO: throw
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

class AdapterForBigInt extends TapeClassAdapter<BigInt> {
  const AdapterForBigInt();

  @override
  BigInt fromFields(Fields fields) {
    final isNegative = fields.get(0, orDefault: false);

    if (!fields.contains(1)) {
      return BigInt.zero;
    }
    final bytes = fields.get(1, orDefault: null);

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
    int bytes = (number.bitLength + 7) >> 3;
    var b256 = BigInt.from(256);
    var result = Uint8List(bytes);
    for (int i = 0; i < bytes; i++) {
      result[i] = number.remainder(b256).toInt();
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
  Block toBlock(DateTime object) => IntBlock(object.microsecondsSinceEpoch);
}

class AdapterForDuration extends TapeAdapter<Duration> {
  const AdapterForDuration();

  @override
  Duration fromBlock(Block block) =>
      Duration(microseconds: block.as<IntBlock>().value);

  @override
  Block toBlock(Duration object) => IntBlock(object.inMicroseconds);
}

class AdapterForRegExp extends TapeClassAdapter<RegExp> {
  const AdapterForRegExp();

  @override
  RegExp fromFields(Fields fields) {
    return RegExp(
      fields.get(0, orDefault: ''), // TODO: throw
      caseSensitive: fields.get(1, orDefault: true),
      multiLine: fields.get(2, orDefault: false),
      unicode: fields.get(3, orDefault: false),
      dotAll: fields.get(4, orDefault: false),
    );
  }

  @override
  Fields toFields(RegExp object) {
    return Fields({
      0: object.pattern,
      1: object.isCaseSensitive,
      2: object.isMultiLine,
      3: object.isUnicode,
      4: object.isDotAll,
    });
  }
}

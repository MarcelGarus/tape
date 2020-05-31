import '../adapters/adapters.dart';

import 'core.dart';
import 'typed_data.dart';

export 'core.dart';
export 'custom.dart';
export 'granular_types.dart';
export 'typed_data.dart';

void registerBuiltInAdapters() {
  _registerCoreAdapters(); // dart:core adapters
  _registerTypedDataAdapters(); // dart:typed_data adapters
}

void _registerCoreAdapters() {
  // Commonly used nodes should be registered first for more efficiency.
  TapeRegistry
    ..registerVirtualNode<Iterable<dynamic>>()
    ..registerVirtualNode<num>()
    ..registerAdapters({
      // Primitive non-collection types.
      -1: AdapterForNull(),
      -2: AdapterForBool(),
      -3: AdapterForString(),
      -4: AdapterForInt(),
      -5: AdapterForDouble(),
      -6: AdapterForBigInt(),
      -7: AdapterForDateTime(),
      -8: AdapterForDuration(),
      // For collection types, we don't want a combinatorial explosion, while
      // still defining some commonly-used adapters. For example, `List<Null>`,
      // which could only contain a sequence of `null`, doesn't really make
      // sense and is thus omitted. Similar reasoning applies to `Set<Null>`,
      // `Map<Null, T>` etc. Note that also, since `double`s are imprecise
      // (because of rounding errors), they're typically not used as map keys,
      // so the corresponding adapters are also not pre-registered here. Having
      // `DateTime`s or `Duration`s are also uncommon as map keys.
      // List adapters.
      -9: AdapterForList<dynamic>(),
      -10: AdapterForList<bool>(),
      -11: AdapterForList<String>(),
      -12: AdapterForList<num>(),
      -13: AdapterForList<int>(),
      -14: AdapterForList<double>(),
      -15: AdapterForList<BigInt>(),
      -16: AdapterForList<DateTime>(),
      -17: AdapterForList<Duration>(),
      // Set adapters.
      -18: AdapterForSet<dynamic>(),
      -19: AdapterForSet<bool>(),
      -20: AdapterForSet<String>(),
      -21: AdapterForSet<num>(),
      -22: AdapterForSet<int>(),
      -23: AdapterForSet<double>(),
      -24: AdapterForSet<BigInt>(),
      -25: AdapterForSet<DateTime>(),
      -26: AdapterForSet<Duration>(),
      // MapEntry adapters.
      -27: AdapterForMap<dynamic, dynamic>(),
      -28: AdapterForMap<dynamic, bool>(),
      -29: AdapterForMap<dynamic, String>(),
      -30: AdapterForMap<dynamic, num>(),
      -31: AdapterForMap<dynamic, int>(),
      -32: AdapterForMap<dynamic, double>(),
      -33: AdapterForMap<dynamic, BigInt>(),
      -34: AdapterForMap<dynamic, DateTime>(),
      -35: AdapterForMap<dynamic, Duration>(),
      -36: AdapterForMap<String, bool>(),
      -37: AdapterForMap<String, bool>(),
      -38: AdapterForMap<String, String>(),
      -39: AdapterForMap<String, num>(),
      -40: AdapterForMap<String, int>(),
      -41: AdapterForMap<String, double>(),
      -42: AdapterForMap<String, BigInt>(),
      -43: AdapterForMap<String, DateTime>(),
      -44: AdapterForMap<String, Duration>(),
      -45: AdapterForMap<int, bool>(),
      -46: AdapterForMap<int, bool>(),
      -47: AdapterForMap<int, String>(),
      -48: AdapterForMap<int, num>(),
      -49: AdapterForMap<int, int>(),
      -50: AdapterForMap<int, double>(),
      -51: AdapterForMap<int, BigInt>(),
      -52: AdapterForMap<int, DateTime>(),
      -53: AdapterForMap<int, Duration>(),
      -54: AdapterForMap<BigInt, bool>(),
      -55: AdapterForMap<BigInt, bool>(),
      -56: AdapterForMap<BigInt, String>(),
      -57: AdapterForMap<BigInt, num>(),
      -58: AdapterForMap<BigInt, int>(),
      -59: AdapterForMap<BigInt, double>(),
      -60: AdapterForMap<BigInt, BigInt>(),
      -61: AdapterForMap<BigInt, DateTime>(),
      -62: AdapterForMap<BigInt, Duration>(),
    });
}

void _registerTypedDataAdapters() {
  TapeRegistry.registerAdapters({
    -70: AdapterForUint8List(),
  });
}

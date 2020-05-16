import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../tape.dart';
import '../type_node.dart';
import '../type_registry.dart';

part 'core.dart';
part 'custom.dart';
part 'typed_data.dart';

void registerBuiltInAdapters(TypeRegistryImpl registry) {
  _registerCoreAdapters(registry); // dart:core adapters
  _registerTypedDataAdapters(registry); // dart:typed_data adapters
}

void _registerCoreAdapters(TypeRegistryImpl registry) {
  // Commonly used nodes should be registered first for more efficiency.
  registry
    ..registerVirtualNode(AdapterNode<Iterable<dynamic>>.virtual())
    ..registerVirtualNode(AdapterNode<num>.virtual())
    ..registerAdapters({
      -1: AdapterForNull(),
      -2: AdapterForBool(),
      -3: AdapterForString(),
      -4: AdapterForInt(),
      -5: AdapterForDouble(),
      -13: AdapterForBigInt(),
      -14: AdapterForDateTime(),
      -15: AdapterForDuration(),
      // List adapters.
      -19: AdapterForList<dynamic>(),
      -22: AdapterForList<String>(),
      -25: AdapterForList<double>(),
      -49: AdapterForList<BigInt>(),
      -50: AdapterForList<DateTime>(),
      -51: AdapterForList<Duration>(),
      // Set adapters.
      -55: AdapterForSet<dynamic>(),
      -56: AdapterForSet<Null>(),
      -57: AdapterForSet<bool>(),
      -58: AdapterForSet<String>(),
      -59: AdapterForSet<double>(),
      -60: AdapterForSet<int>(),
      -61: AdapterForSet<BigInt>(),
      -62: AdapterForSet<DateTime>(),
      -63: AdapterForSet<Duration>(),
      // Map adapters.
      -67: AdapterForMapEntry<dynamic, dynamic>(),
      -68: AdapterForMap<dynamic, dynamic>(),
      -69: AdapterForMap<String, dynamic>(),
      -70: AdapterForMap<String, bool>(),
      -71: AdapterForMap<String, String>(),
      -72: AdapterForMap<String, double>(),
      -73: AdapterForMap<String, int>(),
      -74: AdapterForMap<String, BigInt>(),
      -75: AdapterForMap<String, DateTime>(),
      -76: AdapterForMap<String, Duration>(),
      -77: AdapterForMap<double, dynamic>(),
      -78: AdapterForMap<double, bool>(),
      -79: AdapterForMap<double, String>(),
      -80: AdapterForMap<double, double>(),
      -81: AdapterForMap<double, int>(),
      -82: AdapterForMap<double, BigInt>(),
      -83: AdapterForMap<double, DateTime>(),
      -84: AdapterForMap<double, Duration>(),
      -85: AdapterForMap<int, dynamic>(),
      -86: AdapterForMap<int, bool>(),
      -87: AdapterForMap<int, String>(),
      -88: AdapterForMap<int, double>(),
      -89: AdapterForMap<int, int>(),
      -90: AdapterForMap<int, BigInt>(),
      -91: AdapterForMap<int, DateTime>(),
      -92: AdapterForMap<int, Duration>(),
      -93: AdapterForMap<BigInt, Null>(),
      -94: AdapterForMap<BigInt, bool>(),
      -95: AdapterForMap<BigInt, String>(),
      -96: AdapterForMap<BigInt, double>(),
      -97: AdapterForMap<BigInt, int>(),
      -98: AdapterForMap<BigInt, BigInt>(),
      -99: AdapterForMap<BigInt, DateTime>(),
      -100: AdapterForMap<BigInt, Duration>(),
    });
}

void _registerTypedDataAdapters(TypeRegistryImpl registry) {
  registry.registerAdapters({
    -110: AdapterForUint8List(),
  });
}

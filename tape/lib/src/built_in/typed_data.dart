import 'dart:typed_data';

import 'package:tape/src/blocks/blocks.dart';

import '../adapters/adapters.dart';

/// Adapters for types from `dart:typed_data`.

class AdapterForUint8List extends TapeAdapter<Uint8List> {
  const AdapterForUint8List();

  @override
  Uint8List fromBlock(Block block) =>
      Uint8List.fromList(block.as<BytesBlock>().bytes);

  @override
  Block toBlock(Uint8List object) => BytesBlock(object);
}

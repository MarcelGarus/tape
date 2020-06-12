/// Adapters for types from `dart:typed_data`.

import 'dart:typed_data';

import '../../package.dart';

extension DartTypedDataTaped on TapeApi {
  void registerDartTypedDataAdapters() {
    registerAdapters({
      -80: AdapterForUint8List(),
    });
  }
}

class AdapterForUint8List extends TapeAdapter<Uint8List> {
  const AdapterForUint8List();

  @override
  Uint8List fromBlock(Block block) =>
      Uint8List.fromList(block.as<BytesBlock>().bytes);

  @override
  Block toBlock(Uint8List object) => BytesBlock(object);
}

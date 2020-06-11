import 'dart:convert';

import '../blocks/blocks.dart';
import 'adapter.dart';
import 'errors.dart';

export 'adapter.dart';
export 'errors.dart';

const adapters = _AdaptersCodec();

class _AdaptersCodec extends Codec<Object, Block> {
  const _AdaptersCodec();

  @override
  get encoder => const _AdaptersEncoder();

  @override
  get decoder => const _AdaptersDecoder();
}

class _AdaptersEncoder extends Converter<Object, Block> {
  const _AdaptersEncoder();

  @override
  Block convert(Object object) {
    final adapter = defaultTapeRegistry.adapterByValue(object);
    return TypedBlock(
      typeId: defaultTapeRegistry.idOfAdapter(adapter),
      child: adapter.toBlock(object),
    );
  }
}

class _AdaptersDecoder extends Converter<Block, Object> {
  const _AdaptersDecoder();

  @override
  Object convert(Block block) {
    return defaultTapeRegistry
        .adapterForId(block.as<TypedBlock>().typeId)
        .fromBlock(block);
  }
}

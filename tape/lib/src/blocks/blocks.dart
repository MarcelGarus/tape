import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../errors.dart';

part 'errors.dart';
part 'reader_writer.dart';

part 'blocks/block.dart';
part 'blocks/typed_block.dart';
part 'blocks/safe_block.dart';
part 'blocks/fields_block.dart';
part 'blocks/bytes_block.dart';
part 'blocks/list_block.dart';
part 'blocks/double_block.dart';
part 'blocks/float32_block.dart';
part 'blocks/int_block.dart';
part 'blocks/int8_block.dart';
part 'blocks/int16_block.dart';
part 'blocks/int32_block.dart';
part 'blocks/uint8_block.dart';
part 'blocks/uint16_block.dart';
part 'blocks/uint32_block.dart';

// Used throughout the blocks/... files to generate hashCodes and check equality.
const _dce = DeepCollectionEquality();

const blocks = _BlocksCodec();

class _BlocksCodec extends Codec<Object, List<int>> {
  const _BlocksCodec();

  @override
  get encoder => const _BlocksEncoder();

  @override
  get decoder => const _BlocksDecoder();
}

class _BlocksEncoder extends Converter<Block, List<int>> {
  const _BlocksEncoder();

  @override
  List<int> convert(Block input) => (_Writer()..writeBlock(input)).buffer;
}

class _BlocksDecoder extends Converter<List<int>, Block> {
  const _BlocksDecoder();

  @override
  Block convert(List<int> input) {
    final reader = _Reader(input);
    final block = reader.readBlock();
    if (reader.cursor < input.length) {
      throw BlockEncodingHasExtraBytesException();
    }
    return block;
  }
}

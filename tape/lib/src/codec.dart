import 'dart:convert';

import 'adapters/adapters.dart';
import 'blocks/blocks.dart';

const tape = _TapeCodec();

class _TapeCodec extends Codec<Object, List<int>> {
  const _TapeCodec();

  @override
  Converter<Object, List<int>> get encoder => _TapeEncoder();

  @override
  Converter<List<int>, Object> get decoder => _TapeDecoder();
}

class _TapeEncoder extends Converter<Object, List<int>> {
  const _TapeEncoder();

  @override
  List<int> convert(Object input) {
    final block = adapters.encode(input);
    final bytes = blocks.encode(block);
    return bytes;
  }
}

class _TapeDecoder extends Converter<List<int>, Object> {
  const _TapeDecoder();

  @override
  Object convert(List<int> input) {
    final block = blocks.decode(input);
    final object = adapters.decode(block);
    return object;
  }
}

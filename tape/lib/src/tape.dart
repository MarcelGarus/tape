import 'dart:convert';

import 'adapters/adapters.dart';
import 'blocks/blocks.dart';
import 'built_in/built_in.dart';

/// Adapters get registered here and packages provide initializing extension
/// methods on this object.
final Tape = TapeApi._();

class TapeApi {
  TapeApi._() {
    registerBuiltInAdapters();
  }

  void registerAdapters(
    Map<int, TapeAdapter<dynamic>> adaptersById, {
    bool showWarningForSubtypes = true,
  }) =>
      defaultTapeRegistry.registerAdapters(adaptersById,
          showWarningForSubtypes: showWarningForSubtypes);
}

const tape = _TapeCodec();

class _TapeCodec extends Codec<Object, List<int>> {
  const _TapeCodec();

  @override
  get encoder => _TapeEncoder();

  @override
  get decoder => _TapeDecoder();
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

import 'dart:convert';
import 'dart:typed_data';

import 'type_registry.dart';

part 'tape_reader.dart';
part 'tape_writer.dart';
part 'reader_writer_utils.dart';

/// Adapters get registered here and packages provide initializing extension
/// methods on this object.
const Tape = TapeApi();

class TapeApi {
  const TapeApi();

  void registerAdapters(
    Map<int, AdapterFor<dynamic>> adaptersById, {
    bool showWarningForSubtypes = true,
  }) =>
      TypeRegistry.registerAdapters(adaptersById,
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
  List<int> convert(Object input) =>
      (TapeWriter()..write(input))._dataAsUint8List;
}

class _TapeDecoder extends Converter<List<int>, Object> {
  const _TapeDecoder();

  @override
  Object convert(List<int> input) => TapeReader(input).read<Object>();
}

import 'dart:typed_data';

import 'type_registry.dart';

part 'tape_reader.dart';
part 'tape_writer.dart';
part 'reader_writer_utils.dart';

const Tape = TapeApi();

class TapeApi {
  const TapeApi();

  Uint8List serialize(dynamic object) =>
      (TapeWriter()..write(object))._dataAsUint8List;
  T deserialize<T>(List<int> data) => TapeReader(data).read<T>();

  void registerAdapters(
    Map<int, AdapterFor<dynamic>> adaptersById, {
    bool showWarningForSubtypes = true,
  }) =>
      TypeRegistry.registerAdapters(adaptersById,
          showWarningForSubtypes: showWarningForSubtypes);
}

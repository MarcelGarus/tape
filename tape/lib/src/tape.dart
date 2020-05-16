import 'dart:typed_data';

import 'type_registry.dart';

part 'tape_reader.dart';
part 'tape_writer.dart';

const Tape = TapeApi();

const _reservedTypeIds = 32768;

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

import 'package:meta/meta.dart';

import '../blocks/blocks.dart';
import '../errors.dart';
import 'adapter.dart';

class RegistryError extends TapeError {}

class AdapterError extends TapeError {}

class AdapterAlreadyRegisteredError extends RegistryError {
  AdapterAlreadyRegisteredError({@required this.adapter, @required this.id});

  final TapeAdapter<dynamic> adapter;
  final int id;
}

class AdapterAlreadyRegisteredForDifferentIdError extends RegistryError {
  AdapterAlreadyRegisteredForDifferentIdError({
    @required this.adapter,
    @required this.firstId,
    @required this.secondId,
  });

  final TapeAdapter<dynamic> adapter;
  final int firstId;
  final int secondId;
}

class IdAlreadyInUseError extends RegistryError {
  IdAlreadyInUseError({
    @required this.adapter,
    @required this.id,
    @required this.adapterForId,
  });

  final TapeAdapter<dynamic> adapter;
  final int id;
  final TapeAdapter<dynamic> adapterForId;
}

class UnexpectedBlockError extends AdapterError {
  UnexpectedBlockError(this.block, this.expectedType);

  final Block block;
  final Type expectedType;
}

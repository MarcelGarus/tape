import 'package:meta/meta.dart';

import '../errors.dart';
import 'tape_adapter.dart';

class AdapterError {}

class AdapterAlreadyRegisteredError extends AdapterError {
  AdapterAlreadyRegisteredError({@required this.adapter, @required this.id});

  final TapeAdapter<dynamic> adapter;
  final int id;
}

class AdapterAlreadyRegisteredForDifferentIdError extends TapeError {
  AdapterAlreadyRegisteredForDifferentIdError({
    @required this.adapter,
    @required this.firstId,
    @required this.secondId,
  });

  final TapeAdapter<dynamic> adapter;
  final int firstId;
  final int secondId;
}

class IdAlreadyInUseError extends TapeError {
  IdAlreadyInUseError({
    @required this.adapter,
    @required this.id,
    @required this.adapterForId,
  });

  final TapeAdapter<dynamic> adapter;
  final int id;
  final TapeAdapter<dynamic> adapterForId;
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../errors.dart';

part 'encoder.dart';
part 'errors.dart';
part 'reader_writer.dart';

@sealed
abstract class Block {
  const Block._();
}

/// Annotates the subtree with a [typeId] that indicates which [TapeAdapter] can
/// interpret the blocks.
class TypedBlock implements Block {
  TypedBlock({@required this.typeId, @required this.child})
      : assert(typeId != null),
        assert(child != null);

  final int typeId;
  final Block child;
}

class ListBlock implements Block {
  const ListBlock(this.items) : assert(items != null);

  final List<Block> items;
}

class FieldsBlock implements Block {
  const FieldsBlock(this.fields) : assert(fields != null);

  final Map<int, Block> fields;
}

class BytesBlock implements Block {
  const BytesBlock(this.bytes) : assert(bytes != null);

  final List<int> bytes;
}

class IntBlock implements Block {
  const IntBlock(this.value) : assert(value != null);

  final int value;
}

class DoubleBlock implements Block {
  const DoubleBlock(this.value) : assert(value != null);

  final double value;
}

// More efficient types.

class Uint8Block implements Block {
  const Uint8Block(this.value) : assert(value != null);

  final int value;
}

class Uint16Block implements Block {
  const Uint16Block(this.value) : assert(value != null);

  final int value;
}

class Uint32Block implements Block {
  const Uint32Block(this.value) : assert(value != null);

  final int value;
}

class Int8Block implements Block {
  const Int8Block(this.value) : assert(value != null);

  final int value;
}

class Int16Block implements Block {
  const Int16Block(this.value) : assert(value != null);

  final int value;
}

class Int32Block implements Block {
  const Int32Block(this.value) : assert(value != null);

  final int value;
}

class Float32Block implements Block {
  const Float32Block(this.value) : assert(value != null);

  final double value;
}

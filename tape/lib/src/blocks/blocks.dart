import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../errors.dart';

part 'encoder.dart';
part 'errors.dart';
part 'reader_writer.dart';

const _dce = DeepCollectionEquality();

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

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypedBlock && typeId == other.typeId && child == other.child;
  int get hashCode => runtimeType.hashCode ^ typeId.hashCode ^ child.hashCode;
}

class ListBlock implements Block {
  ListBlock(this.items) : assert(items != null);

  final List<Block> items;

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListBlock && _dce.equals(items, other.items);
  int get hashCode => runtimeType.hashCode ^ _dce.hash(items);
}

class FieldsBlock implements Block {
  FieldsBlock(this.fields) : assert(fields != null);

  final Map<int, Block> fields;

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FieldsBlock && _dce.equals(fields, other.fields);
  int get hashCode => runtimeType.hashCode ^ _dce.hash(fields);
}

class BytesBlock implements Block {
  BytesBlock(this.bytes)
      : assert(bytes != null),
        assert(bytes.every((byte) => byte >= 0 && byte < 256),
            'All bytes need to be between 0 and 256 (0 <= bytes < 256).');

  final List<int> bytes;

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BytesBlock && _dce.equals(bytes, other.bytes);
  int get hashCode => runtimeType.hashCode ^ _dce.hash(bytes);
}

class IntBlock implements Block {
  IntBlock(this.value) : assert(value != null);

  final int value;

  bool operator ==(Object other) =>
      identical(this, other) || other is IntBlock && value == other.value;
  int get hashCode => runtimeType.hashCode ^ value.hashCode;
}

class DoubleBlock implements Block {
  DoubleBlock(this.value) : assert(value != null);

  final double value;

  bool operator ==(Object other) =>
      identical(this, other) || other is DoubleBlock && value == other.value;
  int get hashCode => runtimeType.hashCode ^ value.hashCode;
}

// More efficient types.

class Uint8Block implements Block {
  Uint8Block(this.value)
      : assert(value != null),
        assert(value >= 0),
        assert(value < 256);

  final int value;

  bool operator ==(Object other) =>
      identical(this, other) || other is Uint8Block && value == other.value;
  int get hashCode => runtimeType.hashCode ^ value.hashCode;
}

class Uint16Block implements Block {
  Uint16Block(this.value)
      : assert(value != null),
        assert(value >= 0),
        assert(value < 65536);

  final int value;

  bool operator ==(Object other) =>
      identical(this, other) || other is Uint16Block && value == other.value;
  int get hashCode => runtimeType.hashCode ^ value.hashCode;
}

class Uint32Block implements Block {
  Uint32Block(this.value)
      : assert(value != null),
        assert(value >= 0),
        assert(value < 4294967296);

  final int value;

  bool operator ==(Object other) =>
      identical(this, other) || other is Uint32Block && value == other.value;
  int get hashCode => runtimeType.hashCode ^ value.hashCode;
}

class Int8Block implements Block {
  Int8Block(this.value)
      : assert(value != null),
        assert(value >= -128),
        assert(value < 128);

  final int value;

  bool operator ==(Object other) =>
      identical(this, other) || other is Int8Block && value == other.value;
  int get hashCode => runtimeType.hashCode ^ value.hashCode;
}

class Int16Block implements Block {
  Int16Block(this.value)
      : assert(value != null),
        assert(value >= -32768),
        assert(value < 32767);

  final int value;

  bool operator ==(Object other) =>
      identical(this, other) || other is Int16Block && value == other.value;
  int get hashCode => runtimeType.hashCode ^ value.hashCode;
}

class Int32Block implements Block {
  Int32Block(this.value)
      : assert(value != null),
        assert(value >= -2147483648),
        assert(value < 2147483647);

  final int value;

  bool operator ==(Object other) =>
      identical(this, other) || other is Int32Block && value == other.value;
  int get hashCode => runtimeType.hashCode ^ value.hashCode;
}

class Float32Block implements Block {
  Float32Block(this.value) : assert(value != null);

  final double value;

  bool operator ==(Object other) =>
      identical(this, other) || other is Float32Block && value == other.value;
  int get hashCode => runtimeType.hashCode ^ value.hashCode;
}

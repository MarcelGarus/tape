import 'dart:convert';

import 'package:tape/src/blocks/blocks.dart';

import 'granular_types.dart';
import 'tape_adapter.dart';

class ObjectToBlockEncoder extends Converter<Object, Block> {
  const ObjectToBlockEncoder();

  @override
  Block convert(Object object) {
    if (object == null) {
      return NullBlock();
    } else if (object is bool) {
      return BoolBlock(object);
    } else if (object is Uint8) {
      return Uint8Block(object.toInt());
    } else if (object is Uint16) {
      return Uint16Block(object.toInt());
    } else if (object is Uint32) {
      return Uint32Block(object.toInt());
    } else if (object is Int8) {
      return Int8Block(object.toInt());
    } else if (object is Int16) {
      return Int16Block(object.toInt());
    } else if (object is Int32) {
      return Int32Block(object.toInt());
    } else if (object is int) {
      return IntBlock(object.toInt());
    } else if (object is Float32) {
      return Float32Block(object.toDouble());
    } else if (object is double) {
      return DoubleBlock(object.toDouble());
    } else {
      final adapter = TapeRegistry.adapterByValue(object);
      return adapter.toBlock(object);
    }
  }
}

class BlockToObjectDecoder extends Converter<Block, Object> {
  const BlockToObjectDecoder();

  @override
  Object convert(Block block) {
    if (block == NullBlock) {
      return null;
    } else if (block is BoolBlock) {
      return block.value;
    } else if (block is Uint8Block) {
      return Uint8(block.value);
    } else if (block is Uint16Block) {
      return Uint16(block.value);
    } else if (block is Uint32Block) {
      return Uint32(block.value);
    } else if (block is Int8Block) {
      return Int8(block.value);
    } else if (block is Int16Block) {
      return Int16(block.value);
    } else if (block is Int32Block) {
      return Int32(block.value);
    } else if (block is IntBlock) {
      return block.value;
    } else if (block is Float32Block) {
      return Float32(block.value);
    } else if (block is DoubleBlock) {
      return block.value;
    } else if (block is TypedBlock) {
      return TapeRegistry.adapterForId(block.typeId).fromBlock(block);
    } else if (block is ListBlock || block is ClassBlock) {
      // TODO: throw error
    }
    return unknown;
  }
}

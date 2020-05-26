part of 'blocks.dart';

class BlockError extends TapeError {}

class BlockException extends TapeException {}

/// Tried to encode a [Block] that doesn't match any of the existing, known
/// blocks. This indicates that a user implemented their own [Block], which we
/// don't know how to encode.
class UnsupportedBlockError extends BlockError {
  UnsupportedBlockError(this.block);
  final Block block;
}

/// Tried to decode a [Block], but found a block id that we don't know. New
/// blocks ids shouldn't be added in the future because they corrupt the message
/// for us. Or there should be a transition path that's working.
class UnknownBlockException extends BlockException {}

/// Tried to decode some bytes that are not a valid block format. The
/// format probably ended abruptly or was too long.
class InvalidBlockEncodingException extends BlockException {}

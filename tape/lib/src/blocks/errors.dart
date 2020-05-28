part of 'blocks.dart';

/// During encoding, we should be given a valid tree of blocks. If that's not
/// the case, that's the programmers fault. This shouldn't ever happen during
/// runtime, so it's an [Error].
class BlockEncodingError extends TapeError {}

/// During decoding, we're given some bytes that possibly stem from somewhere
/// else. We don't assume anything about the validity of these bytes. Because
/// they might come from external sources, it's okay if we fail – we just tell
/// our caller that the bytes they received were no valid block encoding.
/// Because it's okay that this happens during runtime, we throw an [Exception].
class BlockDecodingException extends TapeException {}

/// Tried to encode a [Block] that doesn't match any of the existing, known
/// blocks. This indicates that a user implemented or subclassed their own
/// [Block], which we don't know how to encode.
class UnsupportedBlockError extends BlockEncodingError {
  UnsupportedBlockError(this.block);

  final Block block;
}

/// An [UnsupportedBlock] was passed in during encoding. This should never
/// happen as it doesn't have a block id. Instead, it only get created during
/// decoding if we encounter an unknown block id.
class UsedTheUnsupportedBlockError extends BlockEncodingError {}

/// Tried to decode a [Block], but found a block id that we don't know. If new
/// block ids get added, those blocks should be wrapped in [SafeBlock] so that
/// previous decoders still work. [SafeBlock] catches this exception and returns
/// an [UnsupportedBlock] instead.
class UnsupportedBlockException extends BlockDecodingException {
  UnsupportedBlockException(this.id);

  final int id;
}

/// Tried to decode some bytes that are not a valid block encoding, even in
/// future versions.
class InvalidBlockEncodingException extends BlockDecodingException {}

class BlockEncodingEndedAbruptlyException
    extends InvalidBlockEncodingException {}

class BlockEncodingHasExtraBytesException
    extends InvalidBlockEncodingException {}

class SafeBlockWithZeroLengthException extends InvalidBlockEncodingException {}

class SafeBlockLengthDoesNotMatchException
    extends InvalidBlockEncodingException {}

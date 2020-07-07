part of 'blocks.dart';

/// During encoding, we should be given a valid tree of blocks. If that's not
/// the case, that's the programmers fault. This is never supposed to happen
/// during runtime, so it's an [Error].
abstract class BlockEncodingError extends TapeError {
  BlockEncodingError(List<ErrorPart> parts) : super(parts);
}

/// During decoding, we're given some bytes that possibly stem from somewhere
/// else. We don't assume anything about the validity of these bytes. Because
/// they might come from external sources, it's okay if we fail – we just tell
/// our caller that the bytes they received were no valid block encoding.
/// Because it's okay that this happens during runtime, we throw an [Exception]
/// instead of an [Error].
abstract class BlockDecodingException extends TapeException {
  BlockDecodingException(List<ErrorPart> parts) : super(parts);
}

/// Tried to encode a [Block] that doesn't match any of the existing, known
/// blocks. This indicates that a user implemented or subclassed their own
/// [Block], which we don't know how to encode.
class UnsupportedBlockError extends BlockEncodingError {
  UnsupportedBlockError(this.block)
      : assert(block != null),
        super([
          ErrorSummary('You tried to encode an unsupported block.'),
          ErrorText('Tape only supports these predefined block types:\n'
              '${blockTypes.join(', ')}\n'
              "You tried to encode a ${block.runtimeType}, but Tape doesn't "
              'know how to do that.'),
          ErrorCallToAction("Don't create subclasses from Blocks yourself."),
        ]);

  final Block block;
}

/// An [UnsupportedBlock] was passed in during encoding. This should never
/// happen as it doesn't have a block id. Instead, it only get created during
/// decoding if we encounter an unknown block id.
class UsedTheUnsupportedBlockError extends BlockEncodingError {
  UsedTheUnsupportedBlockError()
      : super([
          ErrorSummary('You tried to encode the UnsupportedBlock.'),
          ErrorText('In the future, more blocks might get added to Tape. '
              'If an older version of Tape encounters those new blocks, it '
              "doesn't know how to decode them and throws an "
              'UnsupportedBlockException. To still be able to add blocks '
              "incrementally without breaking previous versions, there's the "
              'SafeBlock, which saves how many bytes the inner block uses. '
              'This allows Tape to replace the subtree of blocks inside the '
              'SafeBlock with an UnsupportedBlock and continue parsing the '
              'rest of the tree. So, UnsupportedBlocks indicate that a part '
              'of the block structure could not be parsed.'),
          ErrorText('In this case, you tried to purposely encode an '
              "UnsupportedBlock. This makes no sense and isn't even possible "
              'because the UnsupportedBlock has no specified encoding format.'),
          ErrorCallToAction("Don't encode UnsupportedBlocks."),
        ]);
}

/// Tried to decode a [Block], but found a block id that we don't know. If new
/// block ids get added, those blocks should be wrapped in [SafeBlock] so that
/// previous decoders still work. [SafeBlock] catches this exception and returns
/// an [UnsupportedBlock] instead.
class UnsupportedBlockException extends BlockDecodingException {
  UnsupportedBlockException(this.id)
      : assert(id != null),
        super([
          ErrorSummary('Encountered an unsupported block during decoding.'),
          ErrorText('In future versions of Tape, new types of blocks might '
              "get added and encoded. That's possible because unlike in JSON, "
              "Tape doesn't use special syntax for each block, but just "
              'encodes the block type as an id. In this case, we encountered '
              "a block id that we don't know: $id"),
          ErrorCallToAction('If your byte input is from an untrusted source, '
              'you should be able to handle all BlockDecodingExceptions '
              'gracefully.'),
          ErrorText("If you're writing or modifying an adapter and you're not "
              'fundamentally changing the meaning of the encoding, consider '
              'using a SafeBlock to wrap the block in question. This allows '
              'older Tape decoders to replace the SafeBlock with an '
              'UnexpectedBlock, but still continue parsing the rest of the '
              'block structure.'),
        ]);

  final int id;
}

/// Tried to decode some bytes that are not a valid block encoding, even in
/// future versions.
abstract class InvalidBlockEncodingException extends BlockDecodingException {
  InvalidBlockEncodingException(List<ErrorPart> parts) : super(parts);
}

class BlockEncodingEndedAbruptlyException
    extends InvalidBlockEncodingException {
  BlockEncodingEndedAbruptlyException()
      : super([
          ErrorSummary('Block encoding ended abruptly.'),
          ErrorText("The encoding isn't complete, there should be more bytes "
              'coming.'),
          ErrorCallToAction('Make sure that you passed all of the bytes to '
              'tape.'),
        ]);
}

class BlockEncodingHasExtraBytesException
    extends InvalidBlockEncodingException {
  BlockEncodingHasExtraBytesException({
    @required this.parsedBlock,
    @required this.offset,
  })  : assert(parsedBlock != null),
        assert(offset != null),
        super([
          ErrorSummary('The block encoding has extra bytes.'),
          ErrorText('There were more bytes available after the root block.'),
          ErrorCallToAction('This may be intentional if you have some bytes '
              'containing multiple Tape-encoded objects. In this case, just '
              'catch this BlockEncodingHasExtraBytesException – it contains '
              'more information like the parsed block (a '
              '${parsedBlock.runtimeType}) and the offset until which Tape '
              'parsed the bytes ($offset).'),
        ]);

  final Block parsedBlock;
  final int offset;
}

class SafeBlockWithZeroLengthException extends InvalidBlockEncodingException {
  SafeBlockWithZeroLengthException()
      : super([
          ErrorSummary('SafeBlock with zero length.'),
          ErrorText('The bytes to encode include a SafeBlock with a zero '
              "length. That shouldn't happen because SafeBlocks always have "
              'a child block.'),
          ErrorCallToAction("If you're not creating your own bytes manually or "
              'bytes from an untrusted source, consider opening an issue at '
              '$repositoryLink/issues/new?template=2-bug.md&labels=bug&'
              'title=SafeBlockWithZeroLengthException+thrown'),
        ]);
}

class SafeBlockLengthDoesNotMatchException
    extends InvalidBlockEncodingException {
  SafeBlockLengthDoesNotMatchException()
      : super([
          ErrorSummary("Safe block length doesn't match the expected one."),
          ErrorText('Tape successfully decoded the child of a SafeBlock, but '
              "its encoding length doesn't match the number of bytes that "
              'the SafeBlocks claims it has.'),
          ErrorCallToAction("This shouldn't happen. Consider opening an "
              'issue at $repositoryLink/issues/new?template=2-bug.md&'
              'labels=bug&title=SafeBlockLengthDoesNotMatchException+thrown'),
        ]);
}

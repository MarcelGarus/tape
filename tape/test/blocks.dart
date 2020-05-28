import 'dart:math';

import 'package:tape/blocks.dart';
import 'package:test/test.dart';

void expectThrows<E>(void Function() callback) =>
    expect(callback, throwsA(isA<E>()));

void expectAssertFailed(void Function() callback) =>
    expectThrows<AssertionError>(callback);

void expectEncoding(Block block, List<int> correctBytes) {
  final bytes = blocks.encode(block);
  expect(bytes, equals(correctBytes));
  final replica = blocks.decode(bytes);
  expect(replica, equals(block));
}

class CustomBlock implements Block {}

void main() {
  group('BytesBlock', () {
    test('encodes and decodes short byte sequence correctly', () {
      expectEncoding(BytesBlock([1, 2, 3]), [2, 0, 0, 0, 3, 1, 2, 3]);
    });

    test('encodes and decodes longer bytes sequence correctly', () {
      expectEncoding(
        BytesBlock([1, 2, 3, 0, 0, 6, 7, 8, 9]),
        [2, 0, 0, 0, 9, 1, 2, 3, 0, 0, 6, 7, 8, 9],
      );
    });

    test('throws when given number that is too big for byte', () {
      expectAssertFailed(() => BytesBlock([1, 2, 300, 2]));
    });

    test('throws when given negative byte', () {
      expectAssertFailed(() => BytesBlock([1, -2, 30, 2]));
    });
  });

  group('IntBlock', () {
    test('encodes and decodes ints correctly', () {
      expectEncoding(IntBlock(7), [4, 0, 0, 0, 0, 0, 0, 0, 7]);
      expectEncoding(IntBlock(42), [4, 0, 0, 0, 0, 0, 0, 0, 42]);
      expectEncoding(IntBlock(1000), [4, 0, 0, 0, 0, 0, 0, 3, 232]);
      expectEncoding(IntBlock(pow(2, 32)), [4, 0, 0, 0, 1, 0, 0, 0, 0]);
      expectEncoding(
        IntBlock(pow(2, 32) - 1),
        [4, 0, 0, 0, 0, 255, 255, 255, 255],
      );
      expectEncoding(IntBlock(-1), [4, 255, 255, 255, 255, 255, 255, 255, 255]);
      expectEncoding(IntBlock(-5), [4, 255, 255, 255, 255, 255, 255, 255, 251]);
      expectEncoding(IntBlock(0), [4, 0, 0, 0, 0, 0, 0, 0, 0]);
    });
  });

  group('Uint8Block', () {
    test('encodes and decodes valid numbers correctly', () {
      expectEncoding(Uint8Block(0), [5, 0]);
      expectEncoding(Uint8Block(12), [5, 12]);
      expectEncoding(Uint8Block(42), [5, 42]);
      expectEncoding(Uint8Block(200), [5, 200]);
    });

    test('throws when given number that is too big', () {
      expectAssertFailed(() => Uint8Block(256));
      expectAssertFailed(() => Uint8Block(300));
      expectAssertFailed(() => Uint8Block(123456));
    });

    test('throws when given number that is negative', () {
      expectAssertFailed(() => Uint8Block(-1));
      expectAssertFailed(() => Uint8Block(-6));
      expectAssertFailed(() => Uint8Block(-256));
    });
  });

  group('Uint16Block', () {
    test('encodes and decodes valid numbers correctly', () {
      expectEncoding(Uint16Block(0), [6, 0, 0]);
      expectEncoding(Uint16Block(42), [6, 0, 42]);
      expectEncoding(Uint16Block(1000), [6, 3, 232]);
      expectEncoding(Uint16Block(pow(2, 16) - 1), [6, 255, 255]);
    });

    test('throws when given number that is too big', () {
      expectAssertFailed(() => Uint16Block(1234567));
      expectAssertFailed(() => Uint16Block(pow(2, 16)));
    });

    test('throws when given number that is negative', () {
      expectAssertFailed(() => Uint16Block(-1));
      expectAssertFailed(() => Uint16Block(-6));
    });
  });

  group('Uint32Block', () {
    test('encodes and decodes valid numbers correctly', () {
      expectEncoding(Uint32Block(0), [7, 0, 0, 0, 0]);
      expectEncoding(Uint32Block(42), [7, 0, 0, 0, 42]);
      expectEncoding(Uint32Block(1000), [7, 0, 0, 3, 232]);
      expectEncoding(Uint32Block(123456789), [7, 7, 91, 205, 21]);
      expectEncoding(Uint32Block(pow(2, 32) - 1), [7, 255, 255, 255, 255]);
    });

    test('throws when given number that is too big', () {
      expectAssertFailed(() => Uint32Block(4294967296));
      expectAssertFailed(() => Uint32Block(1234567890123456789));
    });

    test('throws when given number that is negative', () {
      expectAssertFailed(() => Uint32Block(-1));
      expectAssertFailed(() => Uint32Block(-6));
    });
  });

  group('Int8Block', () {
    test('encodes and decodes valid numbers correctly', () {
      expectEncoding(Int8Block(0), [8, 0]);
      expectEncoding(Int8Block(42), [8, 42]);
      expectEncoding(Int8Block(127), [8, 127]);
      expectEncoding(Int8Block(-1), [8, 255]);
      expectEncoding(Int8Block(-6), [8, 250]);
      expectEncoding(Int8Block(-127), [8, 129]);
      expectEncoding(Int8Block(-128), [8, 128]);
    });

    test('throws when given number that is too big', () {
      expectAssertFailed(() => Int8Block(128));
      expectAssertFailed(() => Int8Block(200));
      expectAssertFailed(() => Int8Block(1234567));
    });

    test('throws when given number that is too small', () {
      expectAssertFailed(() => Int8Block(-129));
      expectAssertFailed(() => Int8Block(-600));
    });
  });

  group('Int16Block', () {
    test('encodes and decodes valid numbers correctly', () {
      expectEncoding(Int16Block(0), [9, 0, 0]);
      expectEncoding(Int16Block(42), [9, 0, 42]);
      expectEncoding(Int16Block(127), [9, 0, 127]);
      expectEncoding(Int16Block(1000), [9, 3, 232]);
      expectEncoding(Int16Block(-1), [9, 255, 255]);
      expectEncoding(Int16Block(-6), [9, 255, 250]);
      expectEncoding(Int16Block(-127), [9, 255, 129]);
      expectEncoding(Int16Block(-128), [9, 255, 128]);
    });

    test('throws when given number that is too big', () {
      expectAssertFailed(() => Int16Block(32767));
      expectAssertFailed(() => Int16Block(1234567));
    });

    test('throws when given number that is too small', () {
      expectAssertFailed(() => Int16Block(-32769));
    });
  });

  group('Int32Block', () {
    test('encodes and decodes valid numbers correctly', () {
      expectEncoding(Int32Block(0), [10, 0, 0, 0, 0]);
      expectEncoding(Int32Block(42), [10, 0, 0, 0, 42]);
      expectEncoding(Int32Block(127), [10, 0, 0, 0, 127]);
      expectEncoding(Int32Block(1000), [10, 0, 0, 3, 232]);
      expectEncoding(Int32Block(1000), [10, 0, 0, 3, 232]);
      expectEncoding(Int32Block(123456789), [10, 7, 91, 205, 21]);
      expectEncoding(Int32Block(-1), [10, 255, 255, 255, 255]);
      expectEncoding(Int32Block(-6), [10, 255, 255, 255, 250]);
      expectEncoding(Int32Block(-127), [10, 255, 255, 255, 129]);
      expectEncoding(Int32Block(-128), [10, 255, 255, 255, 128]);
    });

    test('throws when given number that is too big', () {
      expectAssertFailed(() => Int32Block(2147483647));
      expectAssertFailed(() => Int32Block(12345678901));
    });

    test('throws when given number that is too small', () {
      expectAssertFailed(() => Int32Block(-2147483649));
      expectAssertFailed(() => Int32Block(-3000000000));
    });
  });

  group('DoubleBlock', () {
    test('encodes and decodes doubles correctly', () {
      expectEncoding(DoubleBlock(0.0), [11, 0, 0, 0, 0, 0, 0, 0, 0]);
      expectEncoding(DoubleBlock(2.5), [11, 64, 4, 0, 0, 0, 0, 0, 0]);
      expectEncoding(DoubleBlock(-2.5), [11, 192, 4, 0, 0, 0, 0, 0, 0]);
      expectEncoding(DoubleBlock(200.5), [11, 64, 105, 16, 0, 0, 0, 0, 0]);
      expectEncoding(DoubleBlock(-200.5), [11, 192, 105, 16, 0, 0, 0, 0, 0]);
      expectEncoding(
        DoubleBlock(2.00000125),
        [11, 64, 0, 0, 0, 167, 197, 172, 71],
      );
    });
  });

  group('Float32Block', () {
    test('encodes and decodes floating point numbers correctly', () {
      expectEncoding(Float32Block(0.0), [12, 0, 0, 0, 0]);
      expectEncoding(Float32Block(2.5), [12, 64, 32, 0, 0]);
      expectEncoding(Float32Block(-2.5), [12, 192, 32, 0, 0]);
      expectEncoding(Float32Block(200.5), [12, 67, 72, 128, 0]);
      expectEncoding(Float32Block(-200.5), [12, 195, 72, 128, 0]);
    });
  });

  group('TypedBlock', () {
    test('encodes and decodes correctly', () {
      expectEncoding(
        TypedBlock(typeId: 42, child: Uint8Block(8)),
        [0, 0, 0, 0, 0, 0, 0, 0, 42, 5, 8],
      );
    });
  });

  group('FieldsBlock', () {
    test('encodes and decodes correctly', () {
      expectEncoding(
        FieldsBlock({0: Uint8Block(123), 1: Uint8Block(5), 9: Uint8Block(3)}),
        [1, 0, 0, 0, 3, 0, 0, 0, 0, 5, 123, 0, 0, 0, 1, 5, 5, 0, 0, 0, 9, 5, 3],
      );
    });

    test('throws when given a negative field id', () {
      expectAssertFailed(
        () => FieldsBlock({0: Uint8Block(1), -2: Uint8Block(2)}),
      );
    });
  });

  group('SafeBlock', () {
    test('encodes and decodes properly', () {
      expectEncoding(SafeBlock(child: Uint8Block(42)), [13, 0, 0, 0, 2, 5, 42]);
    });

    test('skips unparseable blocks when decoded', () {
      // ListBlock([Uint8Block(42), SafeBlock(garbage), Uint8Block(3)])
      final bytes = [
        ...[3, 0, 0, 0, 3], // List header
        ...[5, 42], // First element
        ...[13, 0, 0, 0, 4, 255, 255, 255, 255], // SafeBlock with garbage
        ...[5, 3] // Third element
      ];
      final retrieved = blocks.decode(bytes);
      final correct =
          ListBlock([Uint8Block(42), UnsupportedBlock(255), Uint8Block(3)]);
      expect(retrieved, equals(correct));
    });
  });

  test('Throws an error if encoding a custom block', () {
    expectThrows<UnsupportedBlockError>(() => blocks.encode(CustomBlock()));
  });

  test('Throws an error if encoding the UnsupportedBlock', () {
    expectThrows<UsedTheUnsupportedBlockError>(
      () => blocks.encode(UnsupportedBlock(2)),
    );
  });

  test('Throws an exception if decoding a block with an unknown id', () {
    expectThrows<UnsupportedBlockException>(() => blocks.decode([190]));
    expectThrows<UnsupportedBlockException>(() => blocks.decode([21]));
  });

  test('Throws an exception if decoding bytes that stop abruptly', () {
    expectThrows<BlockEncodingEndedAbruptlyException>(() => blocks.decode([]));
  });

  test('Throws an exception if there are more bytes than expected', () {
    expectThrows<BlockEncodingHasExtraBytesException>(
      () => blocks.decode([5, 4, 1]),
    );
  });

  test('Throws an exception if a SafeBlock has a length of zero', () {
    expectThrows<SafeBlockWithZeroLengthException>(
      () => blocks.decode([13, 0, 0, 0, 0]),
    );
  });

  test("Throws an exception if a SafeBlock length doesn't match", () {
    expectThrows<SafeBlockLengthDoesNotMatchException>(
      () => blocks.decode([13, 0, 0, 0, 1, 5, 3]),
    );
  });
}

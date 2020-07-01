import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_taped/flutter_taped.dart';
import 'package:tape/test.dart';

extension TestableAdapter<T> on TapeAdapter<T> {
  T roundtripValue(T value) => fromBlock(toBlock(value));
  void expectSameValueAfterRoundtrip(T value) =>
      expect(roundtripValue(value), equals(value));

  void expectEncoding(T value, Block block) =>
      expect(toBlock(value), equals(block));
  void expectDecoding(Block block, T value) =>
      expect(fromBlock(block), equals(value));
}

void main() {
  group('AdapterForColor', () {
    test('encoding works', () {
      AdapterForColor()
        ..expectSameValueAfterRoundtrip(Colors.blue[500])
        ..expectSameValueAfterRoundtrip(Colors.red.withAlpha(200))
        ..expectSameValueAfterRoundtrip(Colors.pink[300])
        ..expectSameValueAfterRoundtrip(Colors.teal.withOpacity(0.4));
    });

    test('produces expected encoding', () {
      AdapterForColor()
        ..expectEncoding(Colors.blue, Uint32Block(4280391411))
        ..expectEncoding(Colors.teal.withOpacity(0.2), Uint32Block(855676552));
    });

    test('is compatible with all versions', () {
      AdapterForColor()
        ..expectDecoding(Uint32Block(4280391411), Colors.blue[500])
        ..expectDecoding(Uint32Block(855676552), Colors.teal.withOpacity(0.2));
    });
  });
}

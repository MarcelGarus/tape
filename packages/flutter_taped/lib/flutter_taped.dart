library flutter_taped;

import 'dart:ui';

import 'package:tape/package.dart';

extension FlutterTaped on TapeApi {
  void initializeMyPackage() {
    registerAdapters({
      -100: AdapterForColor(),
      -101: AdapterForRect(),
    });
  }
}

class AdapterForColor extends TapeAdapter<Color> {
  @override
  Block toBlock(Color color) {
    return Uint32Block(color.value);
  }

  @override
  Color fromBlock(Block block) {
    return Color(block.as<Uint32Block>().value);
  }
}

class AdapterForRect extends TapeClassAdapter<Rect> {
  const AdapterForRect();

  @override
  Rect fromFields(Fields fields) {
    return Rect.fromLTWH(
      fields.get<double>(0),
      fields.get<double>(1),
      fields.get<double>(2),
      fields.get<double>(3),
    );
  }

  @override
  Fields toFields(Rect rect) {
    return Fields({
      0: rect.left,
      1: rect.top,
      2: rect.width,
      3: rect.height,
    });
  }
}

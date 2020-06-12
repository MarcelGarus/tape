library flutter_taped;

import 'dart:ui';

import 'package:tape/package.dart';

extension FlutterTaped on TapeApi {
  void initializeMyPackage() {
    registerAdapters({
      -20: AdapterForColor(),
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

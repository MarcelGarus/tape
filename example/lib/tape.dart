import 'package:tape/tape.dart';

@TapeInitialization(nextTypeId: 12)
void initializeTape() {
  // 📦 Register adapters that are built-in or that are from taped-packages.
  Tape
    ..registerDartCoreAdapters()
    ..registerDartTypedDataAdapters()
    ..registerDartMathAdapters();

  Tape.registerAdapters({
    // 🌱 For now, it's pretty empty here.
    // Adapters for your types will be registered here.
  });
}

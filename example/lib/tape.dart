import 'package:tape/tape.dart';

@TapeInitialization(nextTypeId: 12)
void initializeTape() {
  // 📦 Register adapters from taped-packages.
  //Tape
  //  ..initializeFlutter()
  //  ..initializeTimeTable()
  //  ..initializeRrule();

  Tape.registerAdapters({
    // 🌱 For now, it's pretty empty here.
    // Adapters for your types will be registered here.
  });
}

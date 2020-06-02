import 'package:tape/tape.dart';

void initialize() {
  // 📦 Register adapters from taped-packages.
  Tape
    ..initializeFlutter()
    ..initializeTimeTable()
    ..initializeRrule();

  Tape.registerAdapters({
    // 🌱 For now, it's pretty empty here.
    // Adapters for types to serialize will get registered here.
  });
}

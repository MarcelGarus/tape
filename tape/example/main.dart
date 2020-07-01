// ignore_for_file: uri_has_not_been_generated, avoid_print

import 'package:meta/meta.dart';
import 'package:tape/tape.dart';

import 'main.g.dart';

@TapeClass(nextFieldId: 3)
class Fruit {
  Fruit({@required this.color, @required this.blub, @required this.amount});

  @TapeField(0, defaultValue: 'red')
  final String color;

  @TapeField(1, defaultValue: true)
  final bool blub;

  @doNotTape
  final int amount;
}

void main() {
  final someFruit = Fruit(color: 'red', blub: true, amount: 1);
  final taped = tape.encode(someFruit);
  print('Fruit taped to $taped.');
}

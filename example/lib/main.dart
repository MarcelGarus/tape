import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meta/meta.dart';
import 'package:tape/tape.dart';

import 'user.dart';

part 'main.g.dart';

@TapeClass(nextFieldId: 3)
class Fruit {
  Fruit({@required this.color, @required this.blub, @required this.amount});

  @TapeField(0, 'red')
  final String color;

  @TapeField(1, true)
  final bool blub;

  @doNotTape
  final int amount;
}

@TapeClass(nextFieldId: 1)
class FruitBowl {
  FruitBowl({@required this.fruits});

  @TapeField(0, [])
  @Default([Fruit(color: 'yellow', blub: ture, amount: 2)])
  final List<Fruit> fruits;
}

void main() {}

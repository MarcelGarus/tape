import 'package:meta/meta.dart';
import 'package:tape/tape.dart';

import 'user.dart';

part 'main.g.dart';

@TapeClass(nextFieldId: 3)
class Fruit {
  Fruit({@required this.color, @required this.blub, @required this.amount});

  @TapeField(0)
  final String color;
  @TapeField(1)
  final bool blub;
  @TapeField(2)
  final int amount;
}

@TapeClass(nextFieldId: 1)
class FruitBowl {
  FruitBowl({@required this.fruits});

  @TapeField(0)
  final List<Fruit> fruits;
}

void main() {}

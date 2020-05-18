import 'package:meta/meta.dart';
import 'package:tape/tape.dart';

import 'user.dart';

part 'main.g.dart';

@TapeType('aVvYHJi6FEuMMc1VBpghBYzpYHgdBzgx')
@TapeClass()
class Fruit {
  Fruit({@required this.color, @required this.blub, @required this.amount});

  @TapeField(0)
  final String color;
  @TapeField(1)
  final bool blub;
  @TapeField(2)
  final int amount;
}

@TapeType('oTWO5bCjZVMDaypmX8wW7yNLkh70HMyz')
@TapeClass()
class FruitBowl {
  FruitBowl({@required this.fruits});

  @TapeField(0)
  final List<Fruit> fruits;
}

void main() {}

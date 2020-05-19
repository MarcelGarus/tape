import 'package:meta/meta.dart';
import 'package:tape/tape.dart';

import 'main.g.dart';

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

void main() {
  final someFruit = Fruit(color: 'red', blub: true, amount: 1);
  final taped = tape(someFruit);
}

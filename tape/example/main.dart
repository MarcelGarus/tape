import 'package:meta/meta.dart';
import 'package:tape/tape.dart';

// ignore: uri_has_not_been_generated
import 'main.g.dart';

@TapeClass(nextFieldId: 3)
class Fruit {
  Fruit({@required this.color, @required this.blub, @required this.amount});

  @TapeField(0, defaultValue: 'red')
  final String color;

  @TapeField(1, true)
  final bool blub;

  @doNotTape
  final int amount;
}

void main() {
  final someFruit = Fruit(color: 'red', blub: true, amount: 1);
  final taped = tape.encode(someFruit);
}

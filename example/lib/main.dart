import 'package:meta/meta.dart';
import 'package:tape/tape.dart';

part 'main.g.dart';

@TapeType(0, 'abcdef123')
class Fruit {
  Fruit({@required this.color, @required this.amount});

  final String color;

  @TapeField(1)
  // @Default(3)
  final int amount;
}

void main() {}
// Hello from the code generator.
// Hello from the code generator.
// Hello from the code generator (from a dynamic path).
// Hello from the code generator (from a dynamic path).
// Hello from the code generator (from a dynamic path).
// Hello from the code generator (from a dynamic path).
// Hello from the code generator (from a dynamic path).

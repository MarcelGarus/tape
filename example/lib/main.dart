import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meta/meta.dart';
import 'package:tape/tape.dart';
import 'tape.dart';
import 'tape.dart';

part 'main.g.dart';
part 'main.freezed.dart';

const dynamic TODO = Object();

@TapeClass(nextFieldId: 3)
class Fruit {
  Fruit({this.name, this.amount, this.isRipe});

  @TapeField(0, defaultValue: TODO)
  String name;

  @TapeField(1, defaultValue: TODO)
  int amount;

  @TapeField(2, defaultValue: TODO)
  bool isRipe;
}

@freezed
abstract class Foo with _$Foo {
  @TapeClass(nextFieldId: 1)
  factory Foo.first({
    @TapeField(1, defaultValue: TODO) String a,
  }) = First;

  // @TapeClass
  factory Foo.second(
    @Default(1234) int b,
    @Default(true) bool c,
  ) = Second;
}

void main() {
  initializeTape();
  print('Hello world');
}

// void main() {
//   initializeTape();
//   final First foo = Foo.first(a: 'bar');
//   foo.a;
//   Tape.registerAdapters({
//     0: AdapterForFruit(),
//   });
//   final apple = Fruit(name: 'apple', amount: 42, isRipe: true);
//   print(tape.encode(apple));
//   // foo.value;
// }

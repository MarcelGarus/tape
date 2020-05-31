import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meta/meta.dart';
import 'package:tape/tape.dart';

part 'main.g.dart';
part 'main.freezed.dart';

const dynamic TODO = Object();

@TapeClass(nextFieldId: 13)
class Fruit {
  Fruit({@required this.color, @required this.blub, @required this.amount});

  @TapeField(4, defaultValue: TODO)
  final String color;

  @doNotTape
  final bool blub;

  @TapeField(9, defaultValue: TODO)
  final int amount;

  @TapeField(12, defaultValue: TODO)
  int hey;
}

// @FreezedTape()
@freezed
abstract class Foo with _$Foo {
  @TapeClass(nextFieldId: 1)
  factory Foo.first(
    @TapeField(0) String a,
  ) = First;

  @TapeClass(nextFieldId: 2)
  factory Foo.second(
    @TapeField(0) int b,
    @TapeField(1) bool c,
  ) = Second;
}

void main() {
  final First foo = Foo.first('bar');
  foo.a;
  // foo.value;
}

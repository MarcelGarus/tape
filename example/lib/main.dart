import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meta/meta.dart';
import 'package:tape/tape.dart';

import 'user.dart';

part 'main.g.dart';

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

// @freezed
// abstract class Foo {
//   factory Foo({
//     String name,
//     int value,
//   }) = _Foo;
// }

void main() {}

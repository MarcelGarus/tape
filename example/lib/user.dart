import 'package:tape/tape.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.g.dart';

@freezed
abstract class Foo with _$Foo {
  @TapeClass(nextFieldId: 2)
  factory Foo.second(
    @TapeField(0, defaultValue: 1234) @Default(1234) int b,
    @TapeField(1, defaultValue: true) @Default(true) bool c,
  ) = Second;
}

// class User<T, S> {
//   User(this.name, this.favorite);

//   @TapeField(0, defaultValue: TODO)
//   final String name;

//   @TapeField(1, defaultValue: TODO)
//   final List<List<T>> favorite;
// }

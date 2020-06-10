import 'package:tape/tape.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.g.dart';
part 'user.freezed.dart';

@freezed
abstract class Foo with _$Foo {
  @TapeClass(nextFieldId: 2)
  factory Foo.second(
    @TapeField(0, defaultValue: TODO) int b,
    @TapeField(1, defaultValue: TODO) bool c,
  ) = Second;
}

// class User<T, S> {
//   User(this.name, this.favorite);

//   @TapeField(0, defaultValue: TODO)
//   final String name;

//   @TapeField(1, defaultValue: TODO)
//   final List<List<T>> favorite;
// }

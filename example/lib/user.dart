import 'package:tape/tape.dart';

part 'user.g.dart';

@TapeClass(nextFieldId: 2)
class User<T, S> {
  User(this.name, this.favorite);

  @TapeField(0, defaultValue: TODO)
  final String name;

  @TapeField(1, defaultValue: TODO)
  final List<List<T>> favorite;
}

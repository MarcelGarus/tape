import 'package:tape/tape.dart';

@TapeClass(nextFieldId: 2)
class User<T, S> {
  User(this.name, this.favorite);

  @TapeField(0, 'Hey')
  final String name;

  @TapeField(1, [])
  final List<List<T>> favorite;
}

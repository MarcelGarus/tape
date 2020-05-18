import 'package:tape/tape.dart';

import 'main.dart';

part 'user.g.dart';

@TapeType('DUgcHXvONuSNbiqEphWwsjYBJYNqE6uW')
@TapeClass()
class User {
  User(this.name, this.favoriteFruit);

  @TapeField(1)
  final String name;

  @TapeField(2)
  final Fruit favoriteFruit;
}

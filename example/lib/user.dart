import 'package:tape/tape.dart';

part 'user.g.dart';

@TapeType('DUgcHXvONuSNbiqEphWwsjYBJYNqE6uW')
class User {
  User(this.name);

  @TapeField(1)
  final String name;
}

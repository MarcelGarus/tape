// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TapeGenerator
// **************************************************************************

class AdapterForUser extends AdapterFor<User> {
  const AdapterForUser();

  @override
  void write(TapeWriter writer, User obj) {
    writer
      ..writeFieldId(1)
      ..write(obj.name)
      ..writeFieldId(2)
      ..write(obj.favoriteFruit);
  }

  @override
  User read(TapeReader reader) {
    final fields = <int, dynamic>{
      for (; reader.hasAvailableBytes;) reader.readFieldId(): reader.read(),
    };

    return User(
      name: fields[1],
      favoriteFruit: fields[2],
    );
  }
}

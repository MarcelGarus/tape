// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TapeGenerator
// **************************************************************************

class AdapterForUser<T, S> extends AdapterFor<User<T, S>> {
  const AdapterForUser();

  @override
  void write(TapeWriter writer, User<T, S> obj) {
    writer
      ..writeFieldId(0)
      ..write(obj.name)
      ..writeFieldId(1)
      ..write(obj.favorite);
  }

  @override
  User<T, S> read(TapeReader reader) {
    final fields = <int, dynamic>{
      for (; reader.hasAvailableBytes;) reader.readFieldId(): reader.read(),
    };

    return User(
      fields[0] as String,
      fields[1] as List<List<T>>,
    );
  }
}

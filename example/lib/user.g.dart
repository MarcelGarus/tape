// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TapeGenerator
// **************************************************************************

class AdapterForUser<T, S> extends TapeClassAdapter<User<T, S>> {
  const AdapterForUser();

  @override
  User<T, S> fromFields(Fields fields) {
    return User<T, S>(
      fields.get<String>(0, orDefault: null),
      fields.get<List<List<T>>>(1, orDefault: null),
    );
  }

  @override
  Fields toFields(User<T, S> object) {
    return Fields({
      0: object.name,
      1: object.favorite,
    });
  }
}

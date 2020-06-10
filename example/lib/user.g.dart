// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TapeGenerator
// **************************************************************************

class AdapterForSecond<T> extends TapeClassAdapter<_$Second<T>> {
  const AdapterForSecond();

  @override
  _$Second<T> fromFields(Fields fields) {
    return _$Second<T>(
      fields.get<int>(0, orDefault: 1234),
      fields.get<bool>(1, orDefault: true),
    );
  }

  @override
  Fields toFields(_$Second<T> object) {
    return Fields({
      0: object.b,
      1: object.c,
    });
  }
}

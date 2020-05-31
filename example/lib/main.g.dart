// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// TapeGenerator
// **************************************************************************

class AdapterForFruit extends TapeClassAdapter<Fruit> {
  const AdapterForFruit();

  @override
  Fruit fromFields(Fields fields) {
    return Fruit(
      color: fields.get<String>(4, orDefault: null),
      amount: fields.get<int>(9, orDefault: null),
    )..hey = fields.get<int>(12, orDefault: null);
  }

  @override
  Fields toFields(Fruit object) {
    return Fields({
      4: object.color,
      9: object.amount,
      12: object.hey,
    });
  }
}

class AdapterForFirst extends TapeClassAdapter<_$First> {
  const AdapterForFirst();

  @override
  _$First fromFields(Fields fields) {
    return _$First(
      fields.get<String>(0, orDefault: null),
    );
  }

  @override
  Fields toFields(_$First object) {
    return Fields({
      0: object.a,
    });
  }
}

class AdapterForSecond extends TapeClassAdapter<_$Second> {
  const AdapterForSecond();

  @override
  _$Second fromFields(Fields fields) {
    return _$Second(
      fields.get<int>(0, orDefault: null),
      fields.get<bool>(1, orDefault: null),
    );
  }

  @override
  Fields toFields(_$Second object) {
    return Fields({
      0: object.b,
      1: object.c,
    });
  }
}

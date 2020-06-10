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
      name: fields.get<String>(0, orDefault: TODO),
      amount: fields.get<int>(1, orDefault: TODO),
      isRipe: fields.get<bool>(2, orDefault: TODO),
    );
  }

  @override
  Fields toFields(Fruit object) {
    return Fields({
      0: object.name,
      1: object.amount,
      2: object.isRipe,
    });
  }
}

class AdapterForFirst extends TapeClassAdapter<_$First> {
  const AdapterForFirst();

  @override
  _$First fromFields(Fields fields) {
    return _$First(
      a: fields.get<String>(1, orDefault: TODO),
    );
  }

  @override
  Fields toFields(_$First object) {
    return Fields({
      1: object.a,
    });
  }
}

class AdapterForSecond extends TapeClassAdapter<_$Second> {
  const AdapterForSecond();

  @override
  _$Second fromFields(Fields fields) {
    return _$Second(
      fields.get<int>(0, orDefault: TODO),
      fields.get<bool>(1, orDefault: TODO),
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

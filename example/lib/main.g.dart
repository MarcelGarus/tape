// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// TapeGenerator
// **************************************************************************

class AdapterForFruit extends AdapterFor<Fruit> {
  const AdapterForFruit();

  @override
  void write(TapeWriter writer, Fruit obj) {
    writer
      ..writeFieldId(0)
      ..write(obj.color)
      ..writeFieldId(1)
      ..write(obj.blub)
      ..writeFieldId(2)
      ..write(obj.amount);
  }

  @override
  Fruit read(TapeReader reader) {
    final fields = <int, dynamic>{
      for (; reader.hasAvailableBytes;) reader.readFieldId(): reader.read(),
    };

    return Fruit(
      color: fields[0] as String,
      blub: fields[1] as bool,
      amount: fields[2] as int,
    );
  }
}

class AdapterForFruitBowl extends AdapterFor<FruitBowl> {
  const AdapterForFruitBowl();

  @override
  void write(TapeWriter writer, FruitBowl obj) {
    writer
      ..writeFieldId(0)
      ..write(obj.fruits);
  }

  @override
  FruitBowl read(TapeReader reader) {
    final fields = <int, dynamic>{
      for (; reader.hasAvailableBytes;) reader.readFieldId(): reader.read(),
    };

    return FruitBowl(
      fruits: fields[0] as List<Fruit>,
    );
  }
}

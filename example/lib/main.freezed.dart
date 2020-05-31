// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named

part of 'main.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

class _$FooTearOff {
  const _$FooTearOff();

  First first(@TapeField(0) String a) {
    return First(
      a,
    );
  }

  Second second(@TapeField(0) int b, @TapeField(1) bool c) {
    return Second(
      b,
      c,
    );
  }
}

// ignore: unused_element
const $Foo = _$FooTearOff();

mixin _$Foo {
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result first(@TapeField(0) String a),
    @required Result second(@TapeField(0) int b, @TapeField(1) bool c),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result first(@TapeField(0) String a),
    Result second(@TapeField(0) int b, @TapeField(1) bool c),
    @required Result orElse(),
  });
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result first(First value),
    @required Result second(Second value),
  });
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result first(First value),
    Result second(Second value),
    @required Result orElse(),
  });
}

abstract class $FooCopyWith<$Res> {
  factory $FooCopyWith(Foo value, $Res Function(Foo) then) =
      _$FooCopyWithImpl<$Res>;
}

class _$FooCopyWithImpl<$Res> implements $FooCopyWith<$Res> {
  _$FooCopyWithImpl(this._value, this._then);

  final Foo _value;
  // ignore: unused_field
  final $Res Function(Foo) _then;
}

abstract class $FirstCopyWith<$Res> {
  factory $FirstCopyWith(First value, $Res Function(First) then) =
      _$FirstCopyWithImpl<$Res>;
  $Res call({@TapeField(0) String a});
}

class _$FirstCopyWithImpl<$Res> extends _$FooCopyWithImpl<$Res>
    implements $FirstCopyWith<$Res> {
  _$FirstCopyWithImpl(First _value, $Res Function(First) _then)
      : super(_value, (v) => _then(v as First));

  @override
  First get _value => super._value as First;

  @override
  $Res call({
    Object a = freezed,
  }) {
    return _then(First(
      a == freezed ? _value.a : a as String,
    ));
  }
}

@TapeClass(nextFieldId: 1)
class _$First implements First {
  _$First(@TapeField(0) this.a) : assert(a != null);

  @override
  @TapeField(0)
  final String a;

  @override
  String toString() {
    return 'Foo.first(a: $a)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is First &&
            (identical(other.a, a) ||
                const DeepCollectionEquality().equals(other.a, a)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(a);

  @override
  $FirstCopyWith<First> get copyWith =>
      _$FirstCopyWithImpl<First>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result first(@TapeField(0) String a),
    @required Result second(@TapeField(0) int b, @TapeField(1) bool c),
  }) {
    assert(first != null);
    assert(second != null);
    return first(a);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result first(@TapeField(0) String a),
    Result second(@TapeField(0) int b, @TapeField(1) bool c),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (first != null) {
      return first(a);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result first(First value),
    @required Result second(Second value),
  }) {
    assert(first != null);
    assert(second != null);
    return first(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result first(First value),
    Result second(Second value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (first != null) {
      return first(this);
    }
    return orElse();
  }
}

abstract class First implements Foo {
  factory First(@TapeField(0) String a) = _$First;

  @TapeField(0)
  String get a;
  $FirstCopyWith<First> get copyWith;
}

abstract class $SecondCopyWith<$Res> {
  factory $SecondCopyWith(Second value, $Res Function(Second) then) =
      _$SecondCopyWithImpl<$Res>;
  $Res call({@TapeField(0) int b, @TapeField(1) bool c});
}

class _$SecondCopyWithImpl<$Res> extends _$FooCopyWithImpl<$Res>
    implements $SecondCopyWith<$Res> {
  _$SecondCopyWithImpl(Second _value, $Res Function(Second) _then)
      : super(_value, (v) => _then(v as Second));

  @override
  Second get _value => super._value as Second;

  @override
  $Res call({
    Object b = freezed,
    Object c = freezed,
  }) {
    return _then(Second(
      b == freezed ? _value.b : b as int,
      c == freezed ? _value.c : c as bool,
    ));
  }
}

@TapeClass(nextFieldId: 2)
class _$Second implements Second {
  _$Second(@TapeField(0) this.b, @TapeField(1) this.c)
      : assert(b != null),
        assert(c != null);

  @override
  @TapeField(0)
  final int b;
  @override
  @TapeField(1)
  final bool c;

  @override
  String toString() {
    return 'Foo.second(b: $b, c: $c)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is Second &&
            (identical(other.b, b) ||
                const DeepCollectionEquality().equals(other.b, b)) &&
            (identical(other.c, c) ||
                const DeepCollectionEquality().equals(other.c, c)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(b) ^
      const DeepCollectionEquality().hash(c);

  @override
  $SecondCopyWith<Second> get copyWith =>
      _$SecondCopyWithImpl<Second>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result first(@TapeField(0) String a),
    @required Result second(@TapeField(0) int b, @TapeField(1) bool c),
  }) {
    assert(first != null);
    assert(second != null);
    return second(b, c);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result first(@TapeField(0) String a),
    Result second(@TapeField(0) int b, @TapeField(1) bool c),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (second != null) {
      return second(b, c);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result first(First value),
    @required Result second(Second value),
  }) {
    assert(first != null);
    assert(second != null);
    return second(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result first(First value),
    Result second(Second value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (second != null) {
      return second(this);
    }
    return orElse();
  }
}

abstract class Second implements Foo {
  factory Second(@TapeField(0) int b, @TapeField(1) bool c) = _$Second;

  @TapeField(0)
  int get b;
  @TapeField(1)
  bool get c;
  $SecondCopyWith<Second> get copyWith;
}

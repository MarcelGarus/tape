// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

part 'user.freezed.g.dart';

T _$identity<T>(T value) => value;

class _$FooTearOff {
  const _$FooTearOff();

  Second<T> second<T>(@TapeField(0, defaultValue: 1234) int b,
      @TapeField(1, defaultValue: true) bool c) {
    return Second<T>(
      b,
      c,
    );
  }
}

// ignore: unused_element
const $Foo = _$FooTearOff();

mixin _$Foo<T> {
  @TapeField(0, defaultValue: 1234)
  int get b;
  @TapeField(1, defaultValue: true)
  bool get c;

  $FooCopyWith<T, Foo<T>> get copyWith;
}

abstract class $FooCopyWith<T, $Res> {
  factory $FooCopyWith(Foo<T> value, $Res Function(Foo<T>) then) =
      _$FooCopyWithImpl<T, $Res>;
  $Res call(
      {@TapeField(0, defaultValue: 1234) int b,
      @TapeField(1, defaultValue: true) bool c});
}

class _$FooCopyWithImpl<T, $Res> implements $FooCopyWith<T, $Res> {
  _$FooCopyWithImpl(this._value, this._then);

  final Foo<T> _value;
  // ignore: unused_field
  final $Res Function(Foo<T>) _then;

  @override
  $Res call({
    Object b = freezed,
    Object c = freezed,
  }) {
    return _then(_value.copyWith(
      b: b == freezed ? _value.b : b as int,
      c: c == freezed ? _value.c : c as bool,
    ));
  }
}

abstract class $SecondCopyWith<T, $Res> implements $FooCopyWith<T, $Res> {
  factory $SecondCopyWith(Second<T> value, $Res Function(Second<T>) then) =
      _$SecondCopyWithImpl<T, $Res>;
  @override
  $Res call(
      {@TapeField(0, defaultValue: 1234) int b,
      @TapeField(1, defaultValue: true) bool c});
}

class _$SecondCopyWithImpl<T, $Res> extends _$FooCopyWithImpl<T, $Res>
    implements $SecondCopyWith<T, $Res> {
  _$SecondCopyWithImpl(Second<T> _value, $Res Function(Second<T>) _then)
      : super(_value, (v) => _then(v as Second<T>));

  @override
  Second<T> get _value => super._value as Second<T>;

  @override
  $Res call({
    Object b = freezed,
    Object c = freezed,
  }) {
    return _then(Second<T>(
      b == freezed ? _value.b : b as int,
      c == freezed ? _value.c : c as bool,
    ));
  }
}

@TapeClass(nextFieldId: 2)
class _$Second<T> implements Second<T> {
  _$Second(@TapeField(0, defaultValue: 1234) this.b,
      @TapeField(1, defaultValue: true) this.c)
      : assert(b != null),
        assert(c != null);

  @override
  @TapeField(0, defaultValue: 1234)
  final int b;
  @override
  @TapeField(1, defaultValue: true)
  final bool c;

  @override
  String toString() {
    return 'Foo<$T>.second(b: $b, c: $c)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is Second<T> &&
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
  $SecondCopyWith<T, Second<T>> get copyWith =>
      _$SecondCopyWithImpl<T, Second<T>>(this, _$identity);
}

abstract class Second<T> implements Foo<T> {
  factory Second(@TapeField(0, defaultValue: 1234) int b,
      @TapeField(1, defaultValue: true) bool c) = _$Second<T>;

  @override
  @TapeField(0, defaultValue: 1234)
  int get b;
  @override
  @TapeField(1, defaultValue: true)
  bool get c;
  @override
  $SecondCopyWith<T, Second<T>> get copyWith;
}

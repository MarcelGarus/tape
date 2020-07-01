class Uint8 {
  Uint8(this._value);

  final int _value;

  int toInt() => _value;

  @override
  bool operator ==(Object other) => other is Uint8 && _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => _value.toString();
}

class Uint16 {
  Uint16(this._value);

  final int _value;

  int toInt() => _value;

  @override
  bool operator ==(Object other) => other is Uint16 && _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => _value.toString();
}

class Uint32 {
  Uint32(this._value);

  final int _value;

  int toInt() => _value;

  @override
  bool operator ==(Object other) => other is Uint32 && _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => _value.toString();
}

class Int8 {
  Int8(this._value);

  final int _value;

  int toInt() => _value;

  @override
  bool operator ==(Object other) => other is Int8 && _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => _value.toString();
}

class Int16 {
  Int16(this._value);

  final int _value;

  int toInt() => _value;

  @override
  bool operator ==(Object other) => other is Int16 && _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => _value.toString();
}

class Int32 {
  Int32(this._value);

  final int _value;

  int toInt() => _value;

  @override
  bool operator ==(Object other) => other is Int32 && _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => _value.toString();
}

class Float32 {
  Float32(this._value);

  final double _value;

  double toDouble() => _value;

  @override
  bool operator ==(Object other) => other is Float32 && _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => _value.toString();
}

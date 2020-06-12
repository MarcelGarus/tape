/// Adapters for types from `dart:math`.

import 'dart:math';

import '../../package.dart';
import 'built_in.dart';

extension DartMathTaped on TapeApi {
  void registerDartMathAdapters() {
    registerAdapters({
      -90: AdapterForMutableRectangle<int>(),
      -91: AdapterForMutableRectangle<double>(),
      -92: AdapterForRectangle<int>(),
      -93: AdapterForRectangle<double>(),
      -94: AdapterForPoint<int>(),
      -95: AdapterForPoint<double>(),
    });
  }
}

class AdapterForMutableRectangle<T extends num>
    extends TapeClassAdapter<MutableRectangle<T>> {
  const AdapterForMutableRectangle();

  @override
  MutableRectangle<T> fromFields(Fields fields) {
    return MutableRectangle(
        fields.get<T>(0), fields.get<T>(1), fields.get<T>(2), fields.get<T>(3));
  }

  @override
  Fields toFields(MutableRectangle<T> rect) {
    return Fields({
      0: rect.left,
      1: rect.top,
      2: rect.width,
      3: rect.height,
    });
  }
}

class AdapterForRectangle<T extends num>
    extends TapeClassAdapter<Rectangle<T>> {
  const AdapterForRectangle();

  @override
  Rectangle<T> fromFields(Fields fields) {
    return Rectangle(
        fields.get<T>(0), fields.get<T>(1), fields.get<T>(2), fields.get<T>(3));
  }

  @override
  Fields toFields(Rectangle<T> rect) {
    return Fields({
      0: rect.left,
      1: rect.top,
      2: rect.width,
      3: rect.height,
    });
  }
}

class AdapterForPoint<T extends num> extends TapeClassAdapter<Point<T>> {
  const AdapterForPoint();

  @override
  Point<T> fromFields(Fields fields) {
    return Point(
      fields.get<T>(0),
      fields.get<T>(1),
    );
  }

  @override
  Fields toFields(Point<T> point) {
    return Fields({
      0: point.x,
      1: point.y,
    });
  }
}

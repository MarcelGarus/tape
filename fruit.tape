// A package for dealing with different kinds of fruit.
package fruit

from duration use Second, Minute, Hour, Something, Else
from rgb-color use Color

from json use Json

// A fruit.
@added(0.1.0)
struct Fruit {
    // How ripe this fruit is.
    ripeness: Ripeness = ripe

    // The color of this fruit.
    color: FruitColor

    // Duration after which this fruit will become overripe.
    @added(0.1.1)
    @deprecated(0.1.2, "This is some reason why this field got deprecated. "
        "Please respect it and carry on. Also, here's some sample text to fill "
        "fill this comment even more: Lorem ipsum, dolor sit amet. Once upon a "
        "time, there was a fancy thing called tape.")
    @deprecated(0.1.2, "This is some reason why this field got deprecated. \
        Please respect it and carry on. Also, here's some sample text to fill \
        fill this comment even more: Lorem ipsum, dolor sit amet. Once upon a \
        time, there was a fancy thing called tape.")
    duration_until_overripe: Duration = zero

    // A secondary color of this fruit.
    @deprecated(0.1.1, "Unused")
    secondary_color: Option<Color> = some(red)
}

enum Ripeness {
    unripe
    ripe
    overripe
}

alias FruitColor = Color

val apple = Fruit {
    ripeness: unripe
    color: green
    duration_until_overripe: oneSecond
}

val someApple = Option.some(apple)

// A package for dealing with different kinds of fruit.
package fruit 0.2.0

get duration 0.2.5
get rgb_color as color from github {
    repo "marcelgarus/color"
    branch "dev"
    path "rgb_color"
}
get utils from path "."

use duration.{Second, Minute, Hour, utils.{Something, Else}}
use color.{Color}

// A fruit.
@added(0.1.0)
struct Fruit {
    // How ripe this fruit is.
    ripeness: Ripeness = ripe

    // The color of this fruit.
    color: FruitColor

    // Duration after which this fruit will become overripe.
    @added(0.1.1)
    @deprecated(0.1.2, "reason "   "and other reason")
    duration_until_overripe: Duration = zero

    // A secondary color of this fruit.
    @deprecated(0.1.1, "Unused")
    secondary_color: Option<Color> = none
}

enum Ripeness {
    unripe
    ripe
    overripe
}

alias FruitColor = Color

const apple = Fruit {
    ripeness: unripe
    color: green
    duration_until_overripe: oneSecond
}

@added(0.1.0)
enum Json {
    Number -> Int
    String -> String
    List -> List<Json>
    Object -> Map<String, Json>
}

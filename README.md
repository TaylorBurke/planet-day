# planet-day

An Apple Watch complication that shows the day of the week as its classical planetary symbol.

| Day | Symbol |
|---|---|
| SUN | ☉ |
| MON | ☽ |
| TUE | ♂ |
| WED | ☿ |
| THU | ♃ |
| FRI | ♀ |
| SAT | ♄ |

## Build

Requires Xcode and [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```sh
brew install xcodegen
xcodegen generate
open PlanetDay.xcodeproj
```

Run the PlanetDay scheme on a watchOS simulator or device, then add "Planet of the Day" from the watch face editor.

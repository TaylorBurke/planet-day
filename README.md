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

Run the **PlanetDayWatch** scheme on a watchOS simulator or device, then add "Planet of the Day" from the watch face editor. Run its tests with ⌘U.

## Release

Archive the **PlanetDay** scheme (the iOS container that wraps the watch-only app, as the App Store requires) with the destination set to **Any iOS Device**, then use Distribute App → App Store Connect in the Organizer.

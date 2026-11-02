import XCTest
@testable import PlanetDay

final class PlanetTests: XCTestCase {
    private var gregorianUTC: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    private func noon(_ year: Int, _ month: Int, _ day: Int) -> Date {
        gregorianUTC.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }

    func test_all_containsSevenPlanetsInWeekdayOrder() {
        XCTAssertEqual(Planet.all.map(\.weekday), Array(1...7))
    }

    func test_ruling_returnsSunForSunday() {
        // 2026-11-01 is a Sunday.
        XCTAssertEqual(Planet.ruling(noon(2026, 11, 1), calendar: gregorianUTC).name, "Sun")
    }

    func test_ruling_mapsEachDayOfAWeekToItsPlanet() {
        let expected = ["Sun", "Moon", "Mars", "Mercury", "Jupiter", "Venus", "Saturn"]
        let names = (0..<7).map { offset in
            Planet.ruling(noon(2026, 11, 1 + offset), calendar: gregorianUTC).name
        }
        XCTAssertEqual(names, expected)
    }

    func test_symbols_useTextPresentationSelector() {
        // Compare scalars: "☉\u{FE0E}" is a single grapheme, so String.hasSuffix won't match.
        let textSelector: Unicode.Scalar = "\u{FE0E}"
        XCTAssertTrue(Planet.all.allSatisfy { $0.symbol.unicodeScalars.last == textSelector })
    }
}

import Foundation

/// The classical planetary ruler of a weekday.
struct Planet: Equatable, Identifiable {
    /// `Calendar` weekday number: 1 = Sunday … 7 = Saturday.
    let weekday: Int
    let symbol: String
    let dayAbbreviation: String
    let name: String

    var id: Int { weekday }

    // "\u{FE0E}" forces text (not emoji) presentation for ♀ ♂ ☿ etc.
    static let all: [Planet] = [
        Planet(weekday: 1, symbol: "☉\u{FE0E}", dayAbbreviation: "SUN", name: "Sun"),
        Planet(weekday: 2, symbol: "☽\u{FE0E}", dayAbbreviation: "MON", name: "Moon"),
        Planet(weekday: 3, symbol: "♂\u{FE0E}", dayAbbreviation: "TUE", name: "Mars"),
        Planet(weekday: 4, symbol: "☿\u{FE0E}", dayAbbreviation: "WED", name: "Mercury"),
        Planet(weekday: 5, symbol: "♃\u{FE0E}", dayAbbreviation: "THU", name: "Jupiter"),
        Planet(weekday: 6, symbol: "♀\u{FE0E}", dayAbbreviation: "FRI", name: "Venus"),
        Planet(weekday: 7, symbol: "♄\u{FE0E}", dayAbbreviation: "SAT", name: "Saturn"),
    ]

    /// The planet ruling the weekday that `date` falls on in `calendar`.
    static func ruling(_ date: Date, calendar: Calendar = .current) -> Planet {
        let weekday = calendar.component(.weekday, from: date)
        return all.first { $0.weekday == weekday } ?? all[0]
    }
}

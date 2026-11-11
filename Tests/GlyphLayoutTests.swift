import XCTest
@testable import PlanetDay

final class GlyphLayoutTests: XCTestCase {
    private let tolerance: CGFloat = 0.0001

    func test_precomputed_hasAnEntryForEveryPlanetSymbol() {
        let missing = Planet.all.map(\.symbol).filter { GlyphLayout.precomputed[$0] == nil }
        XCTAssertTrue(missing.isEmpty, "No precomputed layout for: \(missing)")
    }

    func test_precomputed_matchesLiveCoreTextMeasurement() {
        // Guards against the table drifting from the font. If this fails, paste the
        // printed entries into GlyphLayout.precomputed.
        let mismatches = Planet.all.compactMap { planet -> String? in
            let measured = GlyphLayout.measureUnitLayout(of: planet.symbol)
            guard let stored = GlyphLayout.precomputed[planet.symbol],
                  abs(stored.fontSize - measured.fontSize) < tolerance,
                  abs(stored.offset.width - measured.offset.width) < tolerance,
                  abs(stored.offset.height - measured.offset.height) < tolerance
            else { return measured.tableEntry(for: planet) }
            return nil
        }
        XCTAssertTrue(mismatches.isEmpty, "Update GlyphLayout.precomputed:\n" + mismatches.joined(separator: "\n"))
    }

    func test_init_scalesUnitLayoutLinearlyWithRadius() {
        let symbol = Planet.all[3].symbol // Mercury
        let unit = GlyphLayout(symbol: symbol, targetRadius: 1)
        let scaled = GlyphLayout(symbol: symbol, targetRadius: 42)

        XCTAssertEqual(scaled.fontSize, unit.fontSize * 42, accuracy: tolerance)
        XCTAssertEqual(scaled.offset.width, unit.offset.width * 42, accuracy: tolerance)
        XCTAssertEqual(scaled.offset.height, unit.offset.height * 42, accuracy: tolerance)
    }

    func test_init_fallsBackToMeasurementForUnknownSymbols() {
        let symbol = "♅\u{FE0E}" // Uranus: not in the table
        XCTAssertNil(GlyphLayout.precomputed[symbol])

        let layout = GlyphLayout(symbol: symbol, targetRadius: 10)
        let measured = GlyphLayout.measureUnitLayout(of: symbol)

        XCTAssertEqual(layout.fontSize, measured.fontSize * 10, accuracy: tolerance)
    }
}

private extension GlyphLayout {
    /// Source line for `GlyphLayout.precomputed`, printed when the table is out of date.
    func tableEntry(for planet: Planet) -> String {
        let symbol = planet.symbol.unicodeScalars.first.map { String($0) } ?? planet.symbol
        return String(
            format: "\"%@\\u{FE0E}\": GlyphLayout(fontSize: %.6f, offset: CGSize(width: %.6f, height: %.6f)), // %@",
            symbol, fontSize, offset.width, offset.height, planet.name
        )
    }
}

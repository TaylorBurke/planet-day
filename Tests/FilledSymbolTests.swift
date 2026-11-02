import SwiftUI
import XCTest
@testable import PlanetDay

@MainActor
final class FilledSymbolTests: XCTestCase {
    private let side: CGFloat = 200
    private let minimumFill: CGFloat = 0.85
    private let maximumFill: CGFloat = 0.95
    private let centeringTolerance: CGFloat = 0.04

    func test_everySymbol_fillsNearlyAllOfASquareContainer() throws {
        for planet in Planet.all {
            let bounds = try XCTUnwrap(renderedInkBounds(planet.symbol), "\(planet.name) rendered nothing")
            let fill = max(bounds.width, bounds.height) / side
            XCTAssertGreaterThanOrEqual(fill, minimumFill, "\(planet.name) too small: \(bounds)")
            XCTAssertLessThanOrEqual(fill, maximumFill, "\(planet.name) too large: \(bounds)")
        }
    }

    func test_everySymbol_isCenteredInItsContainer() throws {
        for planet in Planet.all {
            let bounds = try XCTUnwrap(renderedInkBounds(planet.symbol), "\(planet.name) rendered nothing")
            XCTAssertEqual(bounds.midX / side, 0.5, accuracy: centeringTolerance, "\(planet.name) off-centre: \(bounds)")
            XCTAssertEqual(bounds.midY / side, 0.5, accuracy: centeringTolerance, "\(planet.name) off-centre: \(bounds)")
        }
    }

    /// Renders `FilledSymbol` in a `side`×`side` box and returns the bounding box of its drawn pixels, in points.
    private func renderedInkBounds(_ symbol: String) -> CGRect? {
        let renderer = ImageRenderer(content: FilledSymbol(symbol: symbol).frame(width: side, height: side))
        renderer.scale = 1
        guard let image = renderer.cgImage else { return nil }
        return InkBounds.of(image)
    }
}

/// Finds the bounding box of non-transparent pixels in an image.
private enum InkBounds {
    private static let alphaThreshold: UInt8 = 32

    static func of(_ image: CGImage) -> CGRect? {
        let width = image.width, height = image.height, bytesPerRow = width * 4
        var pixels = [UInt8](repeating: 0, count: height * bytesPerRow)
        let drawn: Bool = pixels.withUnsafeMutableBytes { buffer in
            guard let context = CGContext(
                data: buffer.baseAddress, width: width, height: height, bitsPerComponent: 8,
                bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return false }
            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        guard drawn else { return nil }

        var minX = width, minY = height, maxX = -1, maxY = -1
        for y in 0..<height {
            for x in 0..<width where pixels[y * bytesPerRow + x * 4 + 3] > alphaThreshold {
                minX = min(minX, x); maxX = max(maxX, x)
                minY = min(minY, y); maxY = max(maxY, y)
            }
        }
        guard maxX >= 0 else { return nil }
        return CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
    }
}

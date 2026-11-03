import SwiftUI
import XCTest
@testable import PlanetDay

@MainActor
final class FilledSymbolTests: XCTestCase {
    private let side: CGFloat = 200
    /// Circular complications clip everything outside the circle inscribed in the slot,
    /// so the farthest ink must stay within it while still filling most of it.
    private let minimumRadiusFill: CGFloat = 0.85
    private let maximumRadiusFill: CGFloat = 0.95
    private let centeringTolerance: CGFloat = 0.04

    func test_everySymbol_fillsTheCircularSlotWithoutBeingClipped() throws {
        for planet in Planet.all {
            let ink = try XCTUnwrap(renderedInk(planet.symbol), "\(planet.name) rendered nothing")
            let radiusFill = ink.maxDistanceFromCenter / (side / 2)
            XCTAssertGreaterThanOrEqual(radiusFill, minimumRadiusFill, "\(planet.name) too small: \(radiusFill)")
            XCTAssertLessThanOrEqual(radiusFill, maximumRadiusFill, "\(planet.name) would be clipped: \(radiusFill)")
        }
    }

    func test_everySymbol_isCenteredInItsContainer() throws {
        for planet in Planet.all {
            let bounds = try XCTUnwrap(renderedInk(planet.symbol), "\(planet.name) rendered nothing").bounds
            XCTAssertEqual(bounds.midX / side, 0.5, accuracy: centeringTolerance, "\(planet.name) off-centre: \(bounds)")
            XCTAssertEqual(bounds.midY / side, 0.5, accuracy: centeringTolerance, "\(planet.name) off-centre: \(bounds)")
        }
    }

    /// Renders `FilledSymbol` in a `side`×`side` box and measures its drawn pixels, in points.
    private func renderedInk(_ symbol: String) -> InkMetrics? {
        let renderer = ImageRenderer(content: FilledSymbol(symbol: symbol).frame(width: side, height: side))
        renderer.scale = 1
        guard let image = renderer.cgImage else { return nil }
        return InkMetrics.of(image)
    }
}

/// Bounding box of an image's non-transparent pixels, and how far the farthest one is from the image centre.
private struct InkMetrics {
    private static let alphaThreshold: UInt8 = 32

    let bounds: CGRect
    let maxDistanceFromCenter: CGFloat

    static func of(_ image: CGImage) -> InkMetrics? {
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

        let centerX = CGFloat(width) / 2, centerY = CGFloat(height) / 2
        var minX = width, minY = height, maxX = -1, maxY = -1
        var maxDistance: CGFloat = 0
        for y in 0..<height {
            for x in 0..<width where pixels[y * bytesPerRow + x * 4 + 3] > alphaThreshold {
                minX = min(minX, x); maxX = max(maxX, x)
                minY = min(minY, y); maxY = max(maxY, y)
                maxDistance = max(maxDistance, hypot(CGFloat(x) + 0.5 - centerX, CGFloat(y) + 0.5 - centerY))
            }
        }
        guard maxX >= 0 else { return nil }
        return InkMetrics(
            bounds: CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1),
            maxDistanceFromCenter: maxDistance
        )
    }
}

import CoreText
import SwiftUI

/// A planetary symbol scaled so its drawn shape fills nearly all of a circular slot without being clipped.
///
/// A font size alone can't do this: glyphs are much smaller than their line box and
/// each symbol has a different shape, so the actual glyph outline is measured with
/// CoreText and the text is sized and offset to center that outline.
struct FilledSymbol: View {
    /// Fraction of the slot's radius the glyph's farthest point should reach. Circular and
    /// corner complications clip to a circle, so this is measured radially, not by bounding box.
    static let fillFraction: CGFloat = 0.9

    let symbol: String

    var body: some View {
        GeometryReader { geometry in
            let radius = min(geometry.size.width, geometry.size.height) / 2
            let layout = GlyphLayout(symbol: symbol, targetRadius: radius * Self.fillFraction)
            Text(symbol)
                .font(.custom(GlyphLayout.fontName, fixedSize: layout.fontSize))
                .fixedSize()
                .offset(layout.offset)
                .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

/// Font size and offset that center a string's glyph outline and make its farthest point reach `targetRadius`.
struct GlyphLayout {
    /// Measuring and drawing must use the same font. The system font lacks these glyphs,
    /// and CoreText and SwiftUI choose different fallbacks, so name one that has all seven.
    static let fontName = "AppleSymbols"
    private static let referenceFontSize: CGFloat = 100
    /// Max deviation, in points at the reference size, when flattening glyph curves into lines.
    private static let flatteningThreshold: CGFloat = 0.1

    let fontSize: CGFloat
    let offset: CGSize

    init(symbol: String, targetRadius: CGFloat) {
        let font = CTFontCreateWithName(Self.fontName as CFString, Self.referenceFontSize, nil)
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key(kCTFontAttributeName as String): font as Any,
        ]
        let line = CTLineCreateWithAttributedString(NSAttributedString(string: symbol, attributes: attributes))
        let glyphBounds = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds)
        // SwiftUI's Text frame excludes the font's leading, so the measured line box must too.
        let lineBounds = CTLineGetBoundsWithOptions(line, .excludeTypographicLeading)
        let center = CGPoint(x: glyphBounds.midX, y: glyphBounds.midY)
        let outlineRadius = Self.outlinePoints(of: line)
            .map { hypot($0.x - center.x, $0.y - center.y) }
            .max() ?? 0

        guard outlineRadius > 0 else {
            fontSize = targetRadius * 2
            offset = .zero
            return
        }

        let scale = targetRadius / outlineRadius
        fontSize = Self.referenceFontSize * scale
        // CoreText's y axis points up and SwiftUI's points down, hence the sign flip on y.
        offset = CGSize(
            width: (lineBounds.midX - glyphBounds.midX) * scale,
            height: (glyphBounds.midY - lineBounds.midY) * scale
        )
    }

    /// Points along every glyph outline in `line`, in line coordinates, with curves flattened.
    private static func outlinePoints(of line: CTLine) -> [CGPoint] {
        let runs = CTLineGetGlyphRuns(line) as? [CTRun] ?? []
        return runs.flatMap { run -> [CGPoint] in
            let runAttributes = CTRunGetAttributes(run) as NSDictionary
            guard let fontValue = runAttributes[kCTFontAttributeName] else { return [] }
            let runFont = fontValue as! CTFont // swiftlint:disable:this force_cast — CoreText always stores a CTFont here
            let count = CTRunGetGlyphCount(run)
            var glyphs = [CGGlyph](repeating: 0, count: count)
            var positions = [CGPoint](repeating: .zero, count: count)
            CTRunGetGlyphs(run, CFRange(location: 0, length: count), &glyphs)
            CTRunGetPositions(run, CFRange(location: 0, length: count), &positions)
            return zip(glyphs, positions).flatMap { glyph, position in
                var transform = CGAffineTransform(translationX: position.x, y: position.y)
                guard let path = CTFontCreatePathForGlyph(runFont, glyph, &transform) else { return [CGPoint]() }
                return endpoints(of: path.flattened(threshold: flatteningThreshold))
            }
        }
    }

    private static func endpoints(of path: CGPath) -> [CGPoint] {
        var points: [CGPoint] = []
        path.applyWithBlock { element in
            switch element.pointee.type {
            case .moveToPoint, .addLineToPoint:
                points.append(element.pointee.points[0])
            default:
                break
            }
        }
        return points
    }
}

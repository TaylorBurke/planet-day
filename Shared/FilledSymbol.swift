import CoreText
import SwiftUI

/// A planetary symbol scaled so its drawn shape fills nearly all of its container.
///
/// A font size alone can't do this: glyphs are much smaller than their line box and
/// each symbol has a different shape, so the actual glyph outline is measured with
/// CoreText and the text is sized and offset to center that outline.
struct FilledSymbol: View {
    /// Fraction of the container's shorter side the glyph's longest edge should span.
    static let fillFraction: CGFloat = 0.9

    let symbol: String

    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            let layout = GlyphLayout(symbol: symbol, targetSide: side * Self.fillFraction)
            Text(symbol)
                .font(.custom(GlyphLayout.fontName, fixedSize: layout.fontSize))
                .fixedSize()
                .offset(layout.offset)
                .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

/// Font size and offset that make a string's glyph outline span `targetSide` and sit centered.
struct GlyphLayout {
    /// Measuring and drawing must use the same font. The system font lacks these glyphs,
    /// and CoreText and SwiftUI choose different fallbacks, so name one that has all seven.
    static let fontName = "AppleSymbols"
    private static let referenceFontSize: CGFloat = 100

    let fontSize: CGFloat
    let offset: CGSize

    init(symbol: String, targetSide: CGFloat) {
        let font = CTFontCreateWithName(Self.fontName as CFString, Self.referenceFontSize, nil)
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key(kCTFontAttributeName as String): font as Any,
        ]
        let line = CTLineCreateWithAttributedString(NSAttributedString(string: symbol, attributes: attributes))
        let glyphBounds = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds)
        // SwiftUI's Text frame excludes the font's leading, so the measured line box must too.
        let lineBounds = CTLineGetBoundsWithOptions(line, .excludeTypographicLeading)

        let longestEdge = max(glyphBounds.width, glyphBounds.height)
        guard longestEdge > 0 else {
            fontSize = targetSide
            offset = .zero
            return
        }

        let scale = targetSide / longestEdge
        fontSize = Self.referenceFontSize * scale
        // CoreText's y axis points up and SwiftUI's points down, hence the sign flip on y.
        offset = CGSize(
            width: (lineBounds.midX - glyphBounds.midX) * scale,
            height: (glyphBounds.midY - lineBounds.midY) * scale
        )
    }
}

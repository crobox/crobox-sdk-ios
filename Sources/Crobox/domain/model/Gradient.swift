import Foundation

/// A gradient set in a color setting with the Crobox App's gradient input, which stores it as a CSS
/// `linear-gradient(...)` or `radial-gradient(circle, ...)`. A plain color is a gradient of that one color, so that both
/// are drawn the same way.
enum Gradient: Equatable {
    /// A gradient along a line through the center, at `angle` degrees as in CSS: 0 runs from the bottom up, 90 from
    /// left to right, and the angle turns clockwise.
    case linear(angle: CGFloat, stops: [GradientStop])
    /// A circular gradient from the center out to the farthest corner
    case radial(stops: [GradientStop])

    /// The color stops, at least two, in order of their location
    var stops: [GradientStop] {
        switch self {
        case .linear(_, let stops), .radial(let stops):
            return stops
        }
    }
}

/// A color, with components from 0 to 1, at `location` along the gradient, from 0 at its start to 1 at its end
struct GradientStop: Equatable {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
    let location: CGFloat
}

/// Parses a color setting: a gradient, or a plain color as a gradient of that one color
func parseBackground(_ value: String) -> Gradient? {
    if let gradient = parseGradient(value) {
        return gradient
    }
    guard let color = parseColor(value.trimmingCharacters(in: .whitespacesAndNewlines)) else {
        return nil
    }
    return .linear(angle: 180, stops: [0, 1].map {
        GradientStop(red: color.red, green: color.green, blue: color.blue, alpha: color.alpha, location: $0)
    })
}

/// Parses `linear-gradient(<angle>deg, <stops>)` or `radial-gradient(circle, <stops>)`, where each stop is a hex or
/// `rgba(...)` color with an optional percentage, or returns nil for anything else, a plain color included.
func parseGradient(_ value: String) -> Gradient? {
    let css = value.trimmingCharacters(in: .whitespacesAndNewlines)
    guard let open = css.firstIndex(of: "("), css.hasSuffix(")") else {
        return nil
    }
    let function = css[..<open].trimmingCharacters(in: .whitespaces).lowercased()
    let arguments = splitArguments(css[css.index(after: open)..<css.index(before: css.endIndex)])
    switch function {
    case "linear-gradient":
        let angle = arguments.first.flatMap(parseAngle)
        guard let stops = parseStops(angle == nil ? arguments : Array(arguments.dropFirst())) else {
            return nil
        }
        // Without an angle, CSS runs a linear gradient from top to bottom
        return .linear(angle: angle ?? 180, stops: stops)
    case "radial-gradient":
        guard arguments.first?.lowercased() == "circle", let stops = parseStops(Array(arguments.dropFirst())) else {
            return nil
        }
        return .radial(stops: stops)
    default:
        return nil
    }
}

/// The start and end of a CSS linear gradient's line in a `width` by `height` area, with y running down from the top
/// left. The line runs through the center at the angle, and is just long enough for the corners to get the first and
/// last color.
func linearGradientLine(angle: CGFloat, width: CGFloat, height: CGFloat) -> (start: CGPoint, end: CGPoint) {
    let radians = Double(angle) * .pi / 180
    let dx = CGFloat(sin(radians))
    let dy = CGFloat(-cos(radians))
    let half = (abs(width * dx) + abs(height * dy)) / 2
    return (start: CGPoint(x: width / 2 - dx * half, y: height / 2 - dy * half),
            end: CGPoint(x: width / 2 + dx * half, y: height / 2 + dy * half))
}

/// Splits on the commas between arguments, not the ones inside a color such as `rgba(0, 0, 0, 0.5)`
private func splitArguments(_ arguments: Substring) -> [String] {
    var result: [String] = []
    var current = ""
    var depth = 0
    for character in arguments {
        if character == "," && depth == 0 {
            result.append(current.trimmingCharacters(in: .whitespaces))
            current = ""
            continue
        }
        if character == "(" {
            depth += 1
        } else if character == ")" {
            depth -= 1
        }
        current.append(character)
    }
    result.append(current.trimmingCharacters(in: .whitespaces))
    return result
}

private func parseAngle(_ argument: String) -> CGFloat? {
    guard argument.hasSuffix("deg"), let degrees = Double(argument.dropLast(3)) else {
        return nil
    }
    return CGFloat(degrees)
}

private func parseStops(_ arguments: [String]) -> [GradientStop]? {
    guard arguments.count >= 2 else {
        return nil
    }
    var colors: [(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)] = []
    var locations: [CGFloat?] = []
    for argument in arguments {
        let colorEnd: String.Index
        if argument.contains("("), let close = argument.firstIndex(of: ")") {
            colorEnd = argument.index(after: close)
        } else {
            colorEnd = argument.firstIndex(where: { $0.isWhitespace }) ?? argument.endIndex
        }
        guard let color = parseColor(String(argument[..<colorEnd])) else {
            return nil
        }
        colors.append(color)
        let location = argument[colorEnd...].trimmingCharacters(in: .whitespaces)
        if location.isEmpty {
            locations.append(nil)
        } else {
            guard location.hasSuffix("%"), let percentage = Double(location.dropLast()) else {
                return nil
            }
            locations.append(CGFloat(percentage) / 100)
        }
    }
    return zip(colors, resolveLocations(locations)).map { pair in
        let (color, location) = pair
        return GradientStop(red: color.red, green: color.green, blue: color.blue, alpha: color.alpha, location: location)
    }
}

/// Parses a hex or `rgba(r, g, b, a)` color into components from 0 to 1
private func parseColor(_ string: String) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
    if let hex = parseHexColor(string) {
        return (CGFloat(hex.red) / 255, CGFloat(hex.green) / 255, CGFloat(hex.blue) / 255, CGFloat(hex.alpha) / 255)
    }
    guard string.hasPrefix("rgba("), string.hasSuffix(")") else {
        return nil
    }
    let parts = string.dropFirst(5).dropLast().split(separator: ",", omittingEmptySubsequences: false)
    let values = parts.compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
    guard parts.count == 4, values.count == 4 else {
        return nil
    }
    return (CGFloat(values[0]) / 255, CGFloat(values[1]) / 255, CGFloat(values[2]) / 255, CGFloat(values[3]))
}

/// Fills in the locations as CSS does: the first stop defaults to the start and the last to the end, a stop before an
/// earlier one moves up to it, and stops without a location spread evenly between the ones around them.
private func resolveLocations(_ locations: [CGFloat?]) -> [CGFloat] {
    var resolved = locations
    if resolved[0] == nil {
        resolved[0] = 0
    }
    if resolved[resolved.count - 1] == nil {
        resolved[resolved.count - 1] = 1
    }
    var highest = resolved[0]!
    for i in resolved.indices {
        if let location = resolved[i] {
            if location < highest {
                resolved[i] = highest
            } else {
                highest = location
            }
        }
    }
    var i = 1
    while i < resolved.count {
        if resolved[i] == nil {
            let before = i - 1
            let after = (i..<resolved.count).first { resolved[$0] != nil }!
            let from = resolved[before]!
            let step = (resolved[after]! - from) / CGFloat(after - before)
            for j in i..<after {
                resolved[j] = from + step * CGFloat(j - before)
            }
            i = after
        }
        i += 1
    }
    return resolved.map { min(max($0!, 0), 1) }
}

#if canImport(QuartzCore)
import QuartzCore

public extension TextBadge {

    /// Returns a layer that fills its bounds with the background, a plain color or a gradient, or nil when there is
    /// none. Add it as the bottom sublayer of the badge's view, set its frame to the view's bounds in
    /// `layoutSubviews()`, and its `contentsScale` to the screen's scale. Set its `cornerRadius` for rounded corners.
    func backgroundLayer() -> CALayer? {
        return backgroundValue.flatMap(parseBackground).map { BackgroundLayer(gradient: $0) }
    }
}

extension Gradient {

    /// Draws this gradient over a `width` by `height` area of the context, from its origin, with y running down as in
    /// a layer on iOS. The colors mix in sRGB and the gradient's geometry follows CSS, so it looks as it does in a
    /// browser.
    func draw(in context: CGContext, width: CGFloat, height: CGFloat) {
        guard width > 0, height > 0,
              let space = CGColorSpace(name: CGColorSpace.sRGB),
              let gradient = CGGradient(
                colorsSpace: space,
                colors: stops.map { CGColor(srgbRed: $0.red, green: $0.green, blue: $0.blue, alpha: $0.alpha) } as CFArray,
                locations: stops.map(\.location)) else {
            return
        }
        let options: CGGradientDrawingOptions = [.drawsBeforeStartLocation, .drawsAfterEndLocation]
        context.saveGState()
        context.clip(to: CGRect(x: 0, y: 0, width: width, height: height))
        switch self {
        case .linear(let angle, _):
            let line = linearGradientLine(angle: angle, width: width, height: height)
            context.drawLinearGradient(gradient, start: line.start, end: line.end, options: options)
        case .radial:
            let center = CGPoint(x: width / 2, y: height / 2)
            let radius = CGFloat(hypot(Double(width) / 2, Double(height) / 2))
            context.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center,
                                       endRadius: radius, options: options)
        }
        context.restoreGState()
    }
}

/// Draws a badge's background itself rather than with a CAGradientLayer, which mixes colors in another color space and
/// measures a gradient's angle as if the layer were square, so that the badge looks as it does in a browser.
final class BackgroundLayer: CALayer {

    private var gradient: Gradient?

    init(gradient: Gradient) {
        self.gradient = gradient
        super.init()
        needsDisplayOnBoundsChange = true
        masksToBounds = true
        setNeedsDisplay()
    }

    override init(layer: Any) {
        gradient = (layer as? BackgroundLayer)?.gradient
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func draw(in context: CGContext) {
        gradient?.draw(in: context, width: bounds.width, height: bounds.height)
    }
}
#endif

import Foundation

/// Parses a CSS hex color: `#RGB`, `#RGBA`, `#RRGGBB` or `#RRGGBBAA`.
/// Returns the red, green, blue and alpha components (0-255), or nil if the string is not a valid hex color.
func parseHexColor(_ string: String) -> (red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8)? {
    let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.hasPrefix("#") else {
        return nil
    }
    var hex = String(trimmed.dropFirst())
    guard hex.allSatisfy({ $0.isHexDigit }) else {
        return nil
    }
    // Expand the shorthands #RGB and #RGBA to #RRGGBB and #RRGGBBAA
    if hex.count == 3 || hex.count == 4 {
        hex = hex.map { "\($0)\($0)" }.joined()
    }
    // No alpha means fully opaque
    if hex.count == 6 {
        hex += "ff"
    }
    guard hex.count == 8, let value = UInt32(hex, radix: 16) else {
        return nil
    }
    return (red: UInt8((value >> 24) & 0xFF),
            green: UInt8((value >> 16) & 0xFF),
            blue: UInt8((value >> 8) & 0xFF),
            alpha: UInt8(value & 0xFF))
}

#if canImport(UIKit)
import UIKit

public extension TextBadge {
    
    /// font color and opacity as UIColor
    func fontUIColor() -> UIColor? {
        return fontColor.flatMap{ $0.toUIColor() }
    }
    
    /// background color and opacity as UIColor
    func backgroundUIColor() -> UIColor? {
        return backgroundColor.flatMap{ $0.toUIColor() }
    }
    
    /// border color and opacity as UIColor
    func borderUIColor() -> UIColor? {
        return borderColor.flatMap{ $0.toUIColor() }
    }
    
}

public extension SecondaryMessaging {
    
    /// font color and opacity as UIColor
    func fontUIColor() -> UIColor? {
        return fontColor.flatMap{ $0.toUIColor() }
    }
    
}


extension String {
    func toUIColor() -> UIColor? {
        if starts(with: "#") {
            return hexToUIColor()
        } else if starts(with: "rgba") {
            return rgbaToUIColor()
        } else {
            return nil
        }
    }
    
    private func hexToUIColor() -> UIColor? {
        guard let color = parseHexColor(self) else {
            return nil
        }
        return UIColor(red: CGFloat(color.red) / 255,
                       green: CGFloat(color.green) / 255,
                       blue: CGFloat(color.blue) / 255,
                       alpha: CGFloat(color.alpha) / 255)
    }
    
    private func rgbaToUIColor() -> UIColor? {
        let colorArr = deletePrefix("rgba(")
            .deleteSuffix(")")
            .components(separatedBy: ",")
            .map{ $0.trimmingCharacters(in: .whitespacesAndNewlines)}
        guard colorArr.count == 4 else {
            return nil
        }
        
        let red = colorArr[0].toCGFloat()
        let green = colorArr[1].toCGFloat()
        let blue = colorArr[2].toCGFloat()
        let alpha = colorArr[3].toAlpha()

        return UIColor(red: red, green:green, blue:blue, alpha: alpha)
    }
    
    
    private func deletePrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    private func deleteSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
    
    private func toAlpha() -> CGFloat {
        return CGFloat(toFloat())
    }

    private func toCGFloat() -> CGFloat {
        return CGFloat(toFloat() / 255)
    }

    private func toFloat() -> Float {
        return Float(self) ?? 0
    }

}

// MARK: - Helpers

public extension UIColor {

    func hex(hashPrefix: Bool = true) -> String {
        var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0.0, 0.0, 0.0, 0.0)
        getRed(&r, green: &g, blue: &b, alpha: &a)

        let prefix = hashPrefix ? "#" : ""

        return String(format: "\(prefix)%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }

    internal func rgbComponents() -> [CGFloat] {
        var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0.0, 0.0, 0.0, 0.0)
        getRed(&r, green: &g, blue: &b, alpha: &a)

        return [r, g, b]
    }

    var isDark: Bool {
        let RGB = rgbComponents()
        return (0.2126 * RGB[0] + 0.7152 * RGB[1] + 0.0722 * RGB[2]) < 0.5
    }

    var isBlackOrWhite: Bool {
        let RGB = rgbComponents()
        return (RGB[0] > 0.91 && RGB[1] > 0.91 && RGB[2] > 0.91) || (RGB[0] < 0.09 && RGB[1] < 0.09 && RGB[2] < 0.09)
    }

    var isBlack: Bool {
        let RGB = rgbComponents()
        return (RGB[0] < 0.09 && RGB[1] < 0.09 && RGB[2] < 0.09)
    }

    var isWhite: Bool {
        let RGB = rgbComponents()
        return (RGB[0] > 0.91 && RGB[1] > 0.91 && RGB[2] > 0.91)
    }

    func isDistinct(from color: UIColor) -> Bool {
        let bg = rgbComponents()
        let fg = color.rgbComponents()
        let threshold: CGFloat = 0.25
        var result = false

        if abs(bg[0] - fg[0]) > threshold || abs(bg[1] - fg[1]) > threshold || abs(bg[2] - fg[2]) > threshold {
            if abs(bg[0] - bg[1]) < 0.03 && abs(bg[0] - bg[2]) < 0.03 {
                if abs(fg[0] - fg[1]) < 0.03 && abs(fg[0] - fg[2]) < 0.03 {
                    result = false
                }
            }
            result = true
        }

        return result
    }

    func isContrasting(with color: UIColor) -> Bool {
        let bg = rgbComponents()
        let fg = color.rgbComponents()

        let bgLum = 0.2126 * bg[0] + 0.7152 * bg[1] + 0.0722 * bg[2]
        let fgLum = 0.2126 * fg[0] + 0.7152 * fg[1] + 0.0722 * fg[2]
        let contrast = bgLum > fgLum
        ? (bgLum + 0.05) / (fgLum + 0.05)
        : (fgLum + 0.05) / (bgLum + 0.05)

        return 1.6 < contrast
    }

    func alpha(_ value: CGFloat) -> UIColor {
        return withAlphaComponent(value)
    }
}

#endif

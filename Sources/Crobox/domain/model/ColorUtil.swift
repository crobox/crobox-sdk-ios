import Foundation
import Hue

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
        guard starts(with: "#"), count == 7 else {
            return nil
        }
        return UIColor(hex: self)
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
#endif

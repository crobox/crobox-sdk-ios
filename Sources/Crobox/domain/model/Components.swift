import Foundation

public protocol PromotionContentConfig {
    var name: String { get }
}

public struct ImageBadge : PromotionContentConfig {
    public let image: String
    public let altText: String?
    public let name: String
}

public struct TextBadge : PromotionContentConfig {
    public let text: String
    /// font color as hex for colors or rgba for colors with opacity
    public let fontColor: String?
    /// background color as hex for colors or rgba for colors with opacity
    public let backgroundColor: String?
    /// border color as hex for colors or rgba for colors with opacity
    public let borderColor: String?
    public let name: String
}

public struct SecondaryMessaging : PromotionContentConfig {
    public let text: String
    /// font color as hex for colors or rgba for colors with opacity
    public let fontColor: String?
    public let name: String
}

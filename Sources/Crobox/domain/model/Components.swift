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
    public let fontColor: String?
    public let backgroundColor: String?
    public let borderColor: String?
    public let name: String
}

public struct SecondaryMessaging : PromotionContentConfig {
    public let text: String
    public let fontColor: String?
    public let name: String
}

import Foundation

public enum PromotionContentType {
    case image
    case text
}

public protocol PromotionContentConfig {
    var contentType: PromotionContentType { get }
}

public struct ImageBadge : PromotionContentConfig {
    public let image: String
    public let altText: String?
    public let name: String
    public let contentType: PromotionContentType = .image
}

public struct TextBadge : PromotionContentConfig {
    public let text: String
    public let fontColor: String?
    public let backgroundColor: String?
    public let borderColor: String?
    public let name: String
    public let contentType: PromotionContentType = .text
}

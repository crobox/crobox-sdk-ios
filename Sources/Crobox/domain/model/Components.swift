import Foundation

/// What a promotion shows when its campaign uses one of the App components, which the app draws natively
public enum PromotionComponent {
    case textBadge(TextBadge)
    case imageBadge(ImageBadge)
    case secondaryMessaging(SecondaryMessaging)
}

/// An image, from the App image badge
public struct ImageBadge {
    /// The image's URL
    public let imageUrl: URL
    /// Text that describes the image, for VoiceOver
    public let altText: String?
}

/// A short text on a background, from the App text badge. Its colors and background are in `fontColor`,
/// `borderColor` and `backgroundLayer()`.
public struct TextBadge {
    /// The text
    public let text: String
    let fontColorValue: String?
    let backgroundValue: String?
    let borderColorValue: String?
}

/// A line of text, from the App secondary messaging. Its color is in `fontColor`.
public struct SecondaryMessaging {
    /// The text
    public let text: String
    let fontColorValue: String?
}

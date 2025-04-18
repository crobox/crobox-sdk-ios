
import Foundation

/// Promotion Content
public class PromotionContent: NSObject, Decodable {
    /// Message Id of this promotion
    public let messageId: String
    /// Component Name
    public let componentName: String
    
    /**
     * Map of all visual configuration items, managed via Crobox Admin app
     *
     * Example:
     * Map(
     *   "text" : "Best Seller",
     *   "textColor" : "#0e1111"
     *  )
     */
    public var config: [String: String] = [:]

    private enum CodingKeys: String, CodingKey {
        case messageId = "id"
        case componentName = "component"
        case config
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode simple properties
        self.messageId = try container.decode(String.self, forKey: .messageId)
        self.componentName = try container.decode(String.self, forKey: .componentName)

        // Decode `config` dictionary
        self.config = try container.decode([String: String].self, forKey: .config)
    }

    func getValue(_ key: String) -> String? {
        return config[key]
    }
    
    func getValue(forKey key: String, default defaultValue: String) -> String {
        return config[key] ?? defaultValue
    }
    
    public func contentConfig() -> PromotionContentConfig? {
        if (componentName == "mob-app-image-badge.tsx") {
            return getImageBadge()
        } else if (componentName == "mob-app-secondary-messaging.tsx") {
            return getSecondaryMessaging()
        } else if (componentName == "mob-app-text-badge.tsx") {
            return getTextBadge()
        } else {
            return nil
        }
    }
    
    /// Returns image badge configuration with pre-designed configuration keys
    public func getImageBadge() -> ImageBadge? {
        if let image = getValue("image") {
            return ImageBadge(image: image, altText: getValue("altText"), name: componentName)
        } else {
            return nil
        }
    }
    
    /// Returns text badge configuration with pre-designed configuration keys
    public func getTextBadge() -> TextBadge? {
        if let text = getValue("text") {
            return TextBadge(text: text, fontColor: getValue("fontColor"), backgroundColor: getValue("backgroundColor"), borderColor: getValue("borderColor"), name: componentName)
        } else {
            return nil
        }
    }
    
    /// Returns secondary messaging configuration with pre-designed configuration keys
    public func getSecondaryMessaging() -> SecondaryMessaging? {
        if let text = getValue("text") {
            return SecondaryMessaging(text: text, fontColor: getValue("fontColor"), name: componentName)
        } else {
            return nil
        }
    }
    
}

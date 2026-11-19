
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
        self.messageId = (try? container.decode(String.self, forKey: .messageId)) ?? ""
        self.componentName = (try? container.decode(String.self, forKey: .componentName)) ?? ""

        // Decode `config` dictionary. Values that are not strings (numbers, booleans) are converted
        // to strings, and values that cannot be represented (null, objects, arrays) are skipped,
        // so that one unexpected value does not discard the whole config.
        let rawConfig = (try? container.decode([String: LenientConfigValue].self, forKey: .config)) ?? [:]
        self.config = rawConfig.compactMapValues { $0.value }
    }

    func getValue(_ key: String) -> String? {
        return config[key]
    }
    
    func getValue(forKey key: String, default defaultValue: String) -> String {
        return config[key] ?? defaultValue
    }
    
    /// Returns what the promotion shows when its campaign uses one of the App components (`MobAppTextBadgeTsx`,
    /// `MobAppImageBadgeTsx` or `MobAppSecondaryMessagingTsx`), or nil for any other component.
    public func component() -> PromotionComponent? {
        switch componentName {
        case "MobAppTextBadgeTsx":
            return getValue("text").map {
                PromotionComponent.textBadge(TextBadge(text: $0,
                                     fontColorValue: getValue("fontColor"),
                                     backgroundValue: getValue("backgroundColor"),
                                     borderColorValue: getValue("borderColor")))
            }
        case "MobAppImageBadgeTsx":
            return getValue("image").flatMap(imageUrl).map {
                PromotionComponent.imageBadge(ImageBadge(imageUrl: $0, altText: getValue("altText")))
            }
        case "MobAppSecondaryMessagingTsx":
            return getValue("text").map {
                PromotionComponent.secondaryMessaging(SecondaryMessaging(text: $0, fontColorValue: getValue("fontColor")))
            }
        default:
            return nil
        }
    }

    /// Reads an image's address as a URL. The App can store a CDN image without its scheme, as `//cdn.crobox.io/...`,
    /// which an app cannot load, so that gets https.
    private func imageUrl(_ value: String) -> URL? {
        return URL(string: value.hasPrefix("//") ? "https:" + value : value)
    }
}

/// A config value that decodes any scalar JSON value as a String, and anything else as nil.
struct LenientConfigValue: Decodable {
    let value: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            value = string
        } else if let bool = try? container.decode(Bool.self) {
            value = String(bool)
        } else if let int = try? container.decode(Int.self) {
            value = String(int)
        } else if let double = try? container.decode(Double.self) {
            value = String(double)
        } else {
            value = nil
        }
    }
}

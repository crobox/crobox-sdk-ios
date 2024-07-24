
import Foundation
import SwiftyJSON

/// Promotion Content
public class PromotionContent: NSObject {
    /// Message Id of this promotion
    public let messageId: String
    /// Component Name
    public let componentName: String
    
    /**
     * Map of all visual configuration items, managed via Crobox Admin app
     *
     * Example:
     * Map(
     *   "Text1_text" : "Best Seller",
     *   "Text1_color" : "#0e1111"
     *  )
     */
    public var config: [String: String] = [:]
    
    init(jsonData: JSON) {
        self.messageId = jsonData["id"].stringValue
        self.componentName = jsonData["component"].stringValue
        
        let jsonConfig = jsonData["config"]
        for (key, subJson):(String, JSON) in jsonConfig {
            if let stringValue = subJson.string {
                self.config[key] = stringValue
            }
        }
        
    }
    
    func getValue(_ key: String) -> String? {
        return config[key]
    }
    
    func getValue(forKey key: String, default defaultValue: String) -> String {
        return config[key] ?? defaultValue
    }
    
    public lazy var contentConfig: PromotionContentConfig? = if let image = getValue("image") {
        getImageBadge()
    } else {
        getTextBadge()
    }
    
    public lazy var promotionType: PromotionContentType? = contentConfig?.contentType
    
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
}

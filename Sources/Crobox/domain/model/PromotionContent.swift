
import Foundation
import SwiftyJSON

/// Promotion Content
public class PromotionContent: NSObject {
    /// Message Id of this promotion
    public let messageId: String
    /// Component Name
    public let component: String
    
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
        self.component = jsonData["component"].stringValue
        
        let jsonConfig = jsonData["config"]
        for (key, subJson):(String, JSON) in jsonConfig {
            if let stringValue = subJson.string {
                self.config[key] = stringValue
            }
        }
        
    }
    
    func getValue(forKey key: String) -> String? {
        return config[key]
    }
    
    func getValue(forKey key: String, default defaultValue: String) -> String {
        return config[key] ?? defaultValue
    }
    
}


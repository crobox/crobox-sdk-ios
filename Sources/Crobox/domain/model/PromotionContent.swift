
import Foundation
import SwiftyJSON

/**
 Promotion Content
 
 - Parameters
    - id: Message Id of this promotion
    - config: Configuration of each individual item
 */
public class PromotionContent: NSObject {
    
    public let id: String?
    public let config: PromotionConfig?
    
    init(jsonData: JSON) {
        self.id = jsonData["id"].stringValue
        self.config = PromotionConfig(jsonData:jsonData["config"])
    }
}

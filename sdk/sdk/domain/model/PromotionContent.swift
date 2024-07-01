
import Foundation
import SwiftyJSON

public class PromotionContent: NSObject {
    
    public let id: String?
    public let config: PromotionConfig?
    
    init(jsonData: JSON) {
        self.id = jsonData["id"].stringValue
        self.config = PromotionConfig(jsonData:jsonData["config"])
    }
}


import Foundation
import SwiftyJSON

/**
 Represents a promotion calculated
 
 - Parameters:
    - id:Unique id for this promotion
    - productId: Product ID that this promotion was requested for
    - campaignId: The campaign which this promotion belongs to
    - variantId: The variant which this promotion belongs to
    - content: Promotion Content
 */
public class Promotion: NSObject {
    
    public var id: String?
    public var productId: String?
    public var variantId: Int?
    public var campaignId: Int?
    public var content: PromotionContent?
    
    public init(jsonData: JSON) {
        self.id = jsonData["id"].stringValue
        self.productId = jsonData["productId"].stringValue
        self.variantId = jsonData["variantId"].intValue
        self.campaignId = jsonData["campaignId"].intValue
        self.content = PromotionContent(jsonData:jsonData["content"])
    }
}

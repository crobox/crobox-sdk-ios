
import Foundation
import SwiftyJSON

public class Promotion: NSObject {
    
    public var id: String?
    public var productId: String?
    public var experimentId: Int?
    public var variantId: Int?
    public var campaignId: Int?
    public var content: PromotionContent?
    public var parameters: PromotionParameter?
    
    public init(jsonData: JSON) {
        self.id = jsonData["id"].stringValue
        self.productId = jsonData["productId"].stringValue
        self.experimentId = jsonData["experimentId"].intValue
        self.variantId = jsonData["variantId"].intValue
        self.campaignId = jsonData["campaignId"].intValue
        self.content = PromotionContent(jsonData:jsonData["content"])
        self.parameters = PromotionParameter(jsonData:jsonData["parameters"])
    }
}

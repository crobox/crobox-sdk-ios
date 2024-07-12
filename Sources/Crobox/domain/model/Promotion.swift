import Foundation
import SwiftyJSON

/// Represents a promotion calculated
public class Promotion: NSObject {
    
    /// Unique id for this promotion
    public let id: UUID
    /// Product ID that this promotion was requested for
    public let productId: String?
    /// The variant which this promotion belongs to
    public let variantId: Int
    /// The campaign which this promotion belongs to
    public let campaignId: Int
    /// Promotion Content
    public let content: PromotionContent?
    
    public init(jsonData: JSON) throws {
        let idStr = jsonData["id"].stringValue
        if let id = UUID(uuidString: idStr) {
            self.id = id
        } else {
            throw CroboxErrors.invalidUUID(key: "promotion.id", value: idStr)
        }
        self.productId = jsonData["productId"].stringValue
        self.variantId = jsonData["variantId"].intValue
        self.campaignId = jsonData["campaignId"].intValue
        self.content = PromotionContent(jsonData:jsonData["content"])
    }
}

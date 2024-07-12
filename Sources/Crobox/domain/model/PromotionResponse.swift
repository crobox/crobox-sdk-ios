
import Foundation
import SwiftyJSON

/// Promotion Result
public class PromotionResponse: NSObject {
    
    /// The context about campaigns
    public var context: PromotionContext
    /// The promotions calculated
    public var promotions = [Promotion]()
    
    public init(jsonData: JSON) throws {
        
        self.context = try PromotionContext(jsonData:jsonData["context"])
        
        if  let arr = jsonData["promotions"].array {
            for item in arr {
                try self.promotions.append(Promotion(jsonData: item))
            }
        }
    }
}

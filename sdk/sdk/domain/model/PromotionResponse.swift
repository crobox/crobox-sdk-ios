
import Foundation
import SwiftyJSON

public class PromotionResponse: NSObject {
  
    public var context: PromotionContext?
    public var promotions = [Promotion]()
    
    public init(jsonData: JSON) {
        
        self.context = PromotionContext(jsonData:jsonData["context"])
      
        if  let arr = jsonData["promotions"].array {
            for item in arr {
                self.promotions.append(Promotion(jsonData: item))
            }
        }
    }
}

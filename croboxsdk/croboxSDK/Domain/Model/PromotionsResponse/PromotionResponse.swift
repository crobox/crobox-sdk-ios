//
//  PromotionResponse.swift
//  croboxSDK
//
//  Created by idris yıldız on 24.05.2024.
//

import Foundation
import SwiftyJSON

// MARK: - PromotionResponse
public class PromotionResponse: NSObject {
  
    var context: PromotionContext?
    var promotions = [Promotion]()
    
    init(jsonData: JSON) {
        self.context = PromotionContext(jsonData:jsonData["context"])
        if  let arr = jsonData["promotions"].array {
            for item in arr {
                self.promotions.append(Promotion(jsonData: item))
            }
        }
    }
}

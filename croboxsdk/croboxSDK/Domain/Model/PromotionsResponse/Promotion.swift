//
//  Promotion.swift
//  croboxSDK
//
//  Created by idris yıldız on 24.05.2024.
//

import Foundation
import SwiftyJSON

// MARK: - Promotion
class Promotion: NSObject {

    var id: String?
    var productId: String?
    var experimentId: Int?
    var variantId: Int?
    var content: PromotionContent?
    //var parameters: [String: String]?
    
    init(jsonData: JSON) {
        self.id = jsonData["id"].stringValue
        self.productId = jsonData["productId"].stringValue
        self.experimentId = jsonData["experimentId"].intValue
        self.variantId = jsonData["variantId"].intValue
        self.content = PromotionContent(jsonData:jsonData["content"])
        //self.parameters = PromotionParameters(jsonData["parameters"])
    }
}


class PromotionParameters: NSObject {
    var id: String?
    init(jsonData: JSON) {
        self.id = jsonData["id"].stringValue
    }
}

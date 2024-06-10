//
//  Promotion.swift
//  croboxSDK
//
//  Created by crobox team on 24.05.2024.
//

import Foundation
import SwiftyJSON

/*
 id:
 type: string
 description: UUID. Unique id for this promotion (e.g. promoId)
 
 productId:
 type: string
 description: >-
 Product ID that this promotion was requested for (needed for
 overview requests)
 
 experimentId:
 type: integer
 description: The campaign this promotions belongs to
 
 variantId:
 type: integer
 description: The variant this promotions belongs to
 parameters.[key]: // TODO : parameters will be DEPRECATED soon. Ignore this for now!
 type: string
 description: Additional parameters that are used for the trigger values (like {{trigger}} used for XX% discount
 
 */

// MARK: - Promotion
public class Promotion: NSObject {
    
    var id: String?
    var productId: String?
    var experimentId: Int?
    var variantId: Int?
    var campaignId: Int?
    var content: PromotionContent?
    var parameters: PromotionParameter?
    
    init(jsonData: JSON) {
        self.id = jsonData["id"].stringValue
        self.productId = jsonData["productId"].stringValue
        self.experimentId = jsonData["experimentId"].intValue
        self.variantId = jsonData["variantId"].intValue
        self.campaignId = jsonData["campaignId"].intValue
        self.content = PromotionContent(jsonData:jsonData["content"])
        self.parameters = PromotionParameter(jsonData:jsonData["parameters"])
    }
}

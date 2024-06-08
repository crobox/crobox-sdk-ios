//
//  Content.swift
//  croboxSDK
//
//  Created by idris yıldız on 24.05.2024.
//

import Foundation
import SwiftyJSON

/*
 
 id:
 type: string
 format: uuid
 description: Message ID of this promotion
 
 config.[key]:
 type: string
 description: Configuration of each individual configuration item
 
 */


// MARK: - Content
public class PromotionContent: NSObject {
    
    let id: String?
    let config: PromotionConfig?
    
    init(jsonData: JSON) {
        self.id = jsonData["id"].stringValue
        self.config = PromotionConfig(jsonData:jsonData["config"])
    }
}

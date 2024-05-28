//
//  Content.swift
//  croboxSDK
//
//  Created by idris yıldız on 24.05.2024.
//

import Foundation
import SwiftyJSON

// MARK: - Content
class PromotionContent: NSObject {
    
    let id: String?
    let config: PromotionConfig?
    
    init(jsonData: JSON) {
        self.id = jsonData["id"].stringValue
        self.config = PromotionConfig(jsonData:jsonData["config"])
    }
}

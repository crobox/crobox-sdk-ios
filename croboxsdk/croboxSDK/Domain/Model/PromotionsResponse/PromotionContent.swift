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
    let config: Config?
    
    init(jsonData: JSON) {
        self.id = jsonData["id"].stringValue
        self.config = Config(jsonData:jsonData["config"])
    }
}

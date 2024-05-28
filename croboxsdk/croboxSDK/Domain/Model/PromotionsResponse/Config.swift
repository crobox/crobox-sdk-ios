//
//  PromotionConfig.swift
//  croboxSDK
//
//  Created by idris yıldız on 24.05.2024.
//

import Foundation
import SwiftyJSON

// MARK: - Config
class PromotionConfig: NSObject {
    
    var text1Text: String
    var componentBackgroundColor: String
    var text1Color: String
    var componentBorderColor: String
    
    init(jsonData: JSON) {
        self.text1Text = jsonData["Text1_text"].stringValue
        self.componentBackgroundColor = jsonData["Component_backgroundColor"].stringValue
        self.text1Color = jsonData["Text1_color"].stringValue
        self.componentBorderColor = jsonData["Component_borderColor"].stringValue
    }
}

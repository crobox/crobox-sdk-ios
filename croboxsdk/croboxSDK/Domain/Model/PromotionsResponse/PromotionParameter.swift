//
//  PromotionParameter.swift
//  croboxSDK
//
//  Created by idris yıldız on 8.06.2024.
//

import Foundation
<<<<<<< HEAD
=======
import SwiftyJSON

public class PromotionParameter: NSObject {
    
    var data: [String: String] = [:]
    
    init(jsonData: JSON) {
        for (key, subJson):(String, JSON) in jsonData {
            if let stringValue = subJson.string {
                self.data[key] = stringValue
            }
        }
    }

    func getValue(forKey key: String) -> String? {
        return data[key]
    }

    func getValue(forKey key: String, default defaultValue: String) -> String {
        return data[key] ?? defaultValue
    }
}
>>>>>>> ee1dd3e (promotion endpoint: Request / Response model)

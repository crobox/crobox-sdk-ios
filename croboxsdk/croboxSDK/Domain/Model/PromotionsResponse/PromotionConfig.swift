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
    
    var data: [String: String] = [:]
    
    init(jsonData: JSON) {
        for (key, subJson):(String, JSON) in jsonData {
            if let stringValue = subJson.string {
                self.data[key] = stringValue
            }
        }
    }
    
    // İsteğe bağlı: Belirli bir anahtar için değer döndürme işlevi
    func getValue(forKey key: String) -> String? {
        return data[key]
    }
    
    // İsteğe bağlı: Belirli bir anahtar için varsayılan değerle birlikte değer döndürme işlevi
    func getValue(forKey key: String, default defaultValue: String) -> String {
        return data[key] ?? defaultValue
    }
}

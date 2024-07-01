//
//  PromotionConfig.swift
//  croboxSDK
//
//  Created by crobox team on 24.05.2024.
//

import Foundation
import SwiftyJSON

// MARK: - PromotionConfig
public class PromotionConfig: NSObject {
    
    public var data: [String: String] = [:]
    
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
//
//  Experiment.swift
//  croboxSDK
//
//  Created by idris yıldız on 24.05.2024.
//

import Foundation
import SwiftyJSON

// MARK: - Experiment
class Experiment: Codable {
   
    var id: Int?
    var name: String?
    var variantId: Int?
    var variantName: String?
    var control: Bool?
    
    init(jsonData: JSON) {
        self.id = jsonData["groupName"].intValue
        self.name = jsonData["name"].stringValue
        self.variantId = jsonData["variantId"].intValue
        self.variantName = jsonData["variantName"].stringValue
        self.control = jsonData["control"].boolValue
    }
}

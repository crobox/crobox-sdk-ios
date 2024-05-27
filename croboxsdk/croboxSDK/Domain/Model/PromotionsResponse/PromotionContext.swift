//
//  PromotionContext.swift
//  croboxSDK
//
//  Created by idris yıldız on 24.05.2024.
//

import Foundation
import SwiftyJSON

// MARK: - PromotionContext
class PromotionContext: NSObject {
   
    var groupName: String?
    var pid: String?
    var sid: String?
    var experiments = [Experiment]()
    
    init(jsonData: JSON) {
        
        self.groupName = jsonData["groupName"].stringValue
        self.pid = jsonData["pid"].stringValue
        self.sid = jsonData["sid"].stringValue

        if  let arr = jsonData["experiments"].array {
            for item in arr {
                experiments.append(Experiment(jsonData: item))
            }
        }
    }
}

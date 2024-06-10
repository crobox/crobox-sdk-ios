//
//  PromotionContext.swift
//  croboxSDK
//
//  Created by crobox team on 24.05.2024.
//

import Foundation
import SwiftyJSON


/*
 
 groupName:
 type: Optional string
 description: 'List of campaign and variant names, combined '

 pid:
 type: string (of type uuid)
 description: Profile ID

 sid:
 type: Optional string (of uuid)
 description: Session ID

 experiments:
 type: array of ExperimentContextDto's
 description: List of ongoing campaigns
 
 */

// MARK: - PromotionContext
public class PromotionContext: NSObject {
   
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

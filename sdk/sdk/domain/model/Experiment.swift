//
//  Experiment.swift
//  croboxSDK
//
//  Created by crobox team on 24.05.2024.
//

import Foundation
import SwiftyJSON

/*
 id:
 type: integer
 description: Campaign ID

 name:
 type: string
 description: Name of the campaign

 variantId:
 type: integer
 description: Id of the campaign - variant
 variantName:
 type: string
 description: Name of the campaign - variant
 control:
 type: boolean
 description: Indicates if variant is allocated to the control group.
 */

// MARK: - Experiment
public class Experiment: Codable {
   
    public var id: Int?
    public var name: String?
    public var variantId: Int?
    public var variantName: String?
    public var control: Bool?
    
    init(jsonData: JSON) {
        self.id = jsonData["groupName"].intValue
        self.name = jsonData["name"].stringValue
        self.variantId = jsonData["variantId"].intValue
        self.variantName = jsonData["variantName"].stringValue
        self.control = jsonData["control"].boolValue
    }
}

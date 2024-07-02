
import Foundation
import SwiftyJSON

/**
 Represents an ongoing campaign

 - Parameters
    - id:  Campaign ID
    - name: Campaign Name
    - variantId: Id of the Campaign Variant
    - variantName: Name of the Campaign Variant
    - control: Indicates if variant is allocated to the control group
 */
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

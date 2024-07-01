
import Foundation
import SwiftyJSON

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

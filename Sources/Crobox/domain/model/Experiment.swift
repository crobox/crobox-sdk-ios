
import Foundation
import SwiftyJSON

/// Represents an ongoing Campaign
public class Campaign: Codable {
    
    /// Campaign ID
    public let id: Int
    /// Campaign Name
    public let name: String
    /// Id of the Campaign Variant
    public let variantId: Int
    /// Name of the Campaign Variant
    public let variantName: String
    /// Indicates if variant is allocated to the control group
    public let control: Bool
    
    init(jsonData: JSON) {
        self.id = jsonData["id"].intValue
        self.name = jsonData["name"].stringValue
        self.variantId = jsonData["variantId"].intValue
        self.variantName = jsonData["variantName"].stringValue
        self.control = jsonData["control"].boolValue
    }
}

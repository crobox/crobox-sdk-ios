
import Foundation
import SwiftyJSON


/**
 The context about campaigns

 - Parameters
    - campaigns: The list of ongoing campaigns
    - sessionId: Session ID
    - visitorId: Visitor ID
    - groupName: List of campaign and variant names, combined
 */
public class PromotionContext: NSObject {
   
    public var groupName: String?
    public var visitorId: UUID?
    public var sessionId: UUID?
    public var campaigns = [Campaign]()
        
    public init(jsonData: JSON) {
        
        self.groupName = jsonData["groupName"].stringValue
        self.visitorId = UUID(uuidString: jsonData["pid"].stringValue)
        self.sessionId = UUID(uuidString: jsonData["sid"].stringValue)

        if  let arr = jsonData["experiments"].array {
            for item in arr {
                campaigns.append(Campaign(jsonData: item))
            }
        }
    }
}


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
    public var visitorId: String?
    public var sessionId: String?
    public var campaigns = [Campaign]()
    
    
    public init(jsonData: JSON) {
        
        self.groupName = jsonData["groupName"].stringValue
        self.visitorId = jsonData["pid"].stringValue
        self.sessionId = jsonData["sid"].stringValue

        if  let arr = jsonData["experiments"].array {
            for item in arr {
                campaigns.append(Campaign(jsonData: item))
            }
        }
    }
}

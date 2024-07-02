
import Foundation
import SwiftyJSON


/**
 The context about campaigns

 - Parameters
    - experiments: The list of ongoing campaigns
    - sessionId: Session ID
    - visitorId: Visitor ID
    - groupName: List of campaign and variant names, combined
 */
public class PromotionContext: NSObject {
   
    public var groupName: String?
    public var visitorId: String?
    public var sessionId: String?
    public var experiments = [Experiment]()
    
    
    public init(jsonData: JSON) {
        
        self.groupName = jsonData["groupName"].stringValue
        self.visitorId = jsonData["pid"].stringValue
        self.sessionId = jsonData["sid"].stringValue

        if  let arr = jsonData["experiments"].array {
            for item in arr {
                experiments.append(Experiment(jsonData: item))
            }
        }
    }
}


import Foundation
import SwiftyJSON

/// The context about campaigns
public class PromotionContext: NSObject {
    
    /// List of campaign and variant names, combined
    public var groupName: String?
    /// Visitor ID
    public var visitorId: UUID
    /// Session ID
    public var sessionId: UUID
    /// The list of ongoing campaigns
    public var campaigns:[Campaign] = [Campaign]()
    
    public init(jsonData: JSON) throws {
        self.groupName = jsonData["groupName"].stringValue
        
        let visitorIdStr = jsonData["pid"].stringValue
        if let visitorId = UUID(uuidString: visitorIdStr) {
            self.visitorId = visitorId
        } else {
            throw CroboxErrors.invalidUUID(key: "context.visitorId", value: visitorIdStr)
        }
        
        let sessionIdStr = jsonData["sid"].stringValue
        if let sessionId = UUID(uuidString: jsonData["sid"].stringValue) {
            self.sessionId = sessionId
        } else {
            throw CroboxErrors.invalidUUID(key: "context.sessionId", value: sessionIdStr)
        }
        
        if let arr = jsonData["experiments"].array {
            for item in arr {
                campaigns.append(Campaign(jsonData: item))
            }
        }
    }
}


import Foundation
import SwiftyJSON

public class PromotionContext: NSObject {
   
    public var groupName: String?
    public var pid: String?
    public var sid: String?
    public var experiments = [Experiment]()
    
    public init(jsonData: JSON) {
        
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

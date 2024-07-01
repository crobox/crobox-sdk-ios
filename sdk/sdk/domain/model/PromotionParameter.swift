
import Foundation
import SwiftyJSON

public class PromotionParameter: NSObject {
    
    public var data: [String: String] = [:]
    
    init(jsonData: JSON) {
        for (key, subJson):(String, JSON) in jsonData {
            if let stringValue = subJson.string {
                self.data[key] = stringValue
            }
        }
    }

    func getValue(forKey key: String) -> String? {
        return data[key]
    }

    func getValue(forKey key: String, default defaultValue: String) -> String {
        return data[key] ?? defaultValue
    }
}

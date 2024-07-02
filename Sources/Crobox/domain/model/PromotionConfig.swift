
import Foundation
import SwiftyJSON

/**
 Visual configuration elements.
 
 Example:
    ```
    Map(
        "Text1_text" : "Best Seller",
        "Text1_color" : "#0e1111"
    )
    ```
 
 - Parameter data: Map of all visual configuration items, managed via Crobox Admin app
*/
public class PromotionConfig: NSObject {
    
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


import Foundation

class CroboxDebug: NSObject {
    static let shared = CroboxDebug()
    func printText(text:Any)
    {
        if(Crobox.shared.isDebug){
            print(text)
        }
    }
    func promotionError(error:String)
    {
        printError(error: "[Promotion]: \(error)")
        
    }
    func eventError(_ eventType: EventType, _ error: CroboxError)
    {
        printError(error: "[Event]: [\(eventType)]: \(error)")
        
    }
    func printError(error:String)
    {
        printText(text: "[Error]: \(error)")
    }
    
}

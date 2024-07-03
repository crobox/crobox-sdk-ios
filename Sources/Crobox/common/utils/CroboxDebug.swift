
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
    func eventError(error: String)
    {
        printError(error: "[Event]: \(error)")
        
    }
    func printError(error:String)
    {
        printText(text: "[Error]: \(error)")
    }
    
}


import Foundation

class CroboxDebug: NSObject {
    static let shared = CroboxDebug()
    func printText(text:Any)
    {
        if(Crobox.shared.isDebug){
            print(text)
        }
    }
    func printParams(params:[String:Any])
    {
        if(Crobox.shared.isDebug){
            print(params)
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
        if(Crobox.shared.isDebug){
            print("[Error]: \(error)")
        }
    }

}

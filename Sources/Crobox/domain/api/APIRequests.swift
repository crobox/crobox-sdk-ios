
import Foundation
import SwiftyJSON
import Alamofire

class APIRequests: NSObject {
    
    static let shared = APIRequests()
   
    var headers: HTTPHeaders!
    
    func header()
    {
        AF.sessionConfiguration.timeoutIntervalForRequest = 60*5
        headers = [
            .accept("application/json")
        ]
    }
    
    func request(method:HTTPMethod, url: String, parameters:[String: Any], completion: @escaping (_ jsonObject: JSON, _ isSuccess:Bool) -> Void)
    {
        header()
        
        CroboxDebug.shared.printParams(params: parameters)
        
        if NetworkReachabilityManager()!.isReachable {
            AF.request("\(Constant.BASE_URL)\(url)", method: method, parameters: parameters, encoding: URLEncoding(destination: .queryString), headers: headers)
                .validate(statusCode: 200..<501)
                .responseData {
                    response in
                    switch response.result {
                    case .success(let value):
                        CroboxDebug.shared.printText(text: JSON(value))
                        completion(JSON(value), true)
                    case .failure(let error):
                        CroboxDebug.shared.printText(text:JSON(error))
                        completion(JSON(error), false)
                    }
                }
        }else
        {
            do {
                let dictionary: [String: Any] = ["error": "true", "message": "can not get any response from server"]
                let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
                CroboxDebug.shared.printText(text: JSON(jsonData))
                completion(JSON(jsonData), false)
            } catch {
                completion(JSON(), false)
                CroboxDebug.shared.printError(error: "Error converting dictionary to JSON: \(error.localizedDescription)")
            }
        }
    }
}

//
//  APIRequests.swift
//  croboxsdk
//
//  Created by crobox team on 23.05.2024.
//

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
            AF.request("\(Constant.BASE_URL)\(url)", method: method, parameters: parameters, headers: headers)
                .validate(statusCode: 200..<501)
                .responseData {
                    response in
                    switch response.result {
                    case .success(let value):
                        
                        CroboxDebug.shared.printText(text: value.debugDescription)
                        
                        completion(JSON(value), true)
                        
                    case .failure(let error):
                        
                        CroboxDebug.shared.printText(text:error.localizedDescription)
                    
                        completion(JSON(error), false)
                        
                    }
                }
        }else
        {
            do {
                let dictionary: [String: Any] = ["error": "true", "message": "can not get any response from server"]
                let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
                completion(JSON(jsonData), false)
            } catch {
                completion(JSON(), false)
                print("Error converting dictionary to JSON: \(error.localizedDescription)")
            }
        }
    }
}

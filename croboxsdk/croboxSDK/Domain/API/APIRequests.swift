//
//  APIRequests.swift
//  croboxsdk
//
//  Created by idris yıldız on 23.05.2024.
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
    
    func request(method:HTTPMethod, url: String, parameters:[String: Any], completion: @escaping (_ jsonObject: JSON?, _ isSuccess:Bool) -> Void)
    {
        header()
        
        CroboxDebug.shared.printParams(params: parameters)
        
        if NetworkReachabilityManager()!.isReachable {
            AF.request(url, method: method, parameters: parameters, headers: headers)
                .validate(statusCode: 200..<501)
                .responseData {
                    response in
                    switch response.result {
                    case .success(let value):
                        
                        CroboxDebug.shared.printText(text: value.description)
                        
                        completion(JSON(value),true)
                        
                    case .failure(let error):
                        
                        CroboxDebug.shared.printText(text:error.localizedDescription)
                    
                        completion(nil, false)
                        
                    }
                }
        }else
        {
            completion(nil, false)
        }
    }
}

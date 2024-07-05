
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
    
    func request(method:HTTPMethod, url: String, parameters:[String: String], closure: @escaping (_ result: Result<Void, CroboxError>) -> Void)
    {
        header()
        
        CroboxDebug.shared.printText(text: "\(url) \(parameters)")
        
        if NetworkReachabilityManager()!.isReachable {
            AF.request("\(url)", method: method, parameters: parameters, encoding: URLEncoding(destination: .queryString), headers: headers)
                .validate(statusCode: 200..<501)
                .responseData {
                    response in
                    switch response.result {
                    case .success(_):
                        closure(.success(()))
                    case .failure(let error):
                        CroboxDebug.shared.printText(text:error.localizedDescription)
                        closure(.failure(CroboxError.httpError(statusCode: response.response?.statusCode ?? -1, data: response.data)))
                        
                    }
                }
        } else {
            closure(.failure(CroboxError.internalError(msg: "can not get any response from server")))
        }
    }
}

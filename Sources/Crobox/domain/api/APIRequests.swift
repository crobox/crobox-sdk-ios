
import Foundation
import SwiftyJSON
import Alamofire

class APIRequests: NSObject {
    
    static let shared = APIRequests()
    
    var headers: HTTPHeaders!
    
    func header()
    {
        AF.sessionConfiguration.timeoutIntervalForRequest = 60*5
    }
    
    func request(method:HTTPMethod, url: String, parameters:[String: String], closure: @escaping (_ result: Result<Void, CroboxError>) -> Void)
    {
        header()
        
        if NetworkReachabilityManager()!.isReachable {
            AF.request("\(url)", method: method, parameters: parameters, encoding: URLEncoding(destination: .queryString))
                .validate(statusCode: 200..<501)
                .responseData {
                    response in
                    switch response.result {
                    case .success(_):
                        closure(.success(()))
                    case .failure(let error):
                        closure(.failure(CroboxError.httpError(statusCode: response.response?.statusCode ?? -1, error: error)))
                    }
                }
        } else {
            closure(.failure(CroboxError.internalError(msg: "Network status unreachable")))
        }
    }
}

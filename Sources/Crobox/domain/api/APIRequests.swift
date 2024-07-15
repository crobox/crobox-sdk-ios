
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
    
    func get(url: String, parameters:[String: String], closure: @escaping (_ result: Result<Void, CroboxErrors>) -> Void)
    {
        header()
        
        AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding(destination: .queryString))
            .validate()
            .responseData {
                response in
                switch response.result {
                case .success(_):
                    closure(.success(()))
                case .failure(let error):
                    closure(.failure(CroboxErrors.httpError(statusCode: response.response?.statusCode ?? -1, cause: error)))
                }
            }
    }
    
    func post(url: URL, body: String, closure: @escaping (_ result: Result<Data, CroboxErrors>) -> Void)
    {
        var urlRequest = URLRequest(url: url)
        urlRequest.method = .post
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = body.data(using: .utf8)
        
        AF.request(urlRequest)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let responseData):
                    closure(.success(responseData))
                case .failure(let afError):
                    closure(.failure(CroboxErrors.httpError(statusCode: response.response?.statusCode ?? -1, cause: afError)))
                }
            }
    }
}

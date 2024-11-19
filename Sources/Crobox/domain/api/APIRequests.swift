
import Foundation
import SwiftyJSON
import Alamofire

class APIRequests: NSObject {
    
    static let shared = APIRequests()
    
    var session: Session!
    var headers: HTTPHeaders!
    
    func header()
    {
        AF.sessionConfiguration.timeoutIntervalForRequest = 60*5
        let combinedInterceptor = Interceptor(interceptors: [UserAgentInterceptor()])
        session = Session(interceptor: combinedInterceptor)
    }
    
    func get(url: String, parameters:[String: String]) async throws -> Void {
        header()
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(url, method: .get, parameters: parameters, encoding: URLEncoding(destination: .queryString))
                .validate()
                .responseData {
                    response in
                    switch response.result {
                    case .success(_):
                        continuation.resume()
                    case .failure(let error):
                        continuation.resume(throwing: CroboxErrors.httpError(statusCode: response.response?.statusCode ?? -1, cause: error))
                    }
                }
        }
    }
    
    func post(url: URL, body: String) async throws -> Data {
        var urlRequest = URLRequest(url: url)
        urlRequest.method = .post
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = body.data(using: .utf8)
        
        return try await withCheckedThrowingContinuation{ continuation in
            session.request(urlRequest)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let responseData):
                        continuation.resume(returning: responseData)
                    case .failure(let afError):
                        continuation.resume(throwing: CroboxErrors.httpError(statusCode: response.response?.statusCode ?? -1, cause: afError))
                    }
                }
        }
    }
}

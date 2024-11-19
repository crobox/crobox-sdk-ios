//
//  File.swift
//  Crobox
//
//  Created by Taras Teslyuk on 18.11.2024.
//

import Alamofire
import Foundation

class UserAgentInterceptor: RequestInterceptor {
    
    // This function allows you to adapt and modify the request before it's sent
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var adaptedRequest = urlRequest
        
        // Add the User-Agent header
        let userAgent = "iOS SDK: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")/\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")"
        adaptedRequest.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        // Return the adapted request
        completion(.success(adaptedRequest))
    }
}

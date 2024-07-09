import Foundation
import Alamofire

public enum CroboxError : Error {
    case invalidJSON(msg: String)
    case httpError(statusCode: Int, error: AFError?)
    case internalError(msg: String)
    case networkError(msg: String)
    case otherError(msg: String, cause: Error)
}

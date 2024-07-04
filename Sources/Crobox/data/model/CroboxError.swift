import Foundation

public enum CroboxError : Error {
    case invalidJSON(msg: String)
    case httpError(statusCode: Int, data: Data?)
    case internalError(msg: String)
    case otherError(msg: String, cause: Error)
}

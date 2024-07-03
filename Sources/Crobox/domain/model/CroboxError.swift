import Foundation

public enum CroboxError : Error {
    case invalidJSON(msg: String)
    case httpError(statusCode: Int, msg: String?)
    case internalError(msg: String)
}

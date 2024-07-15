import Foundation

public enum CroboxErrors: Error {
    case invalidUUID(key: String, value: String)
    case invalidJSON(msg: String, value: String)
    case httpError(statusCode: Int, cause: Error)
    case internalRequestError(msg: String)
    case internalError(msg: String, cause: Error)
}

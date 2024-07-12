import Foundation

enum CroboxErrors: Error {
    case invalidUUID(key: String, value: String)
}

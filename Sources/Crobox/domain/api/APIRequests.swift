
import Foundation

class APIRequests: NSObject {

    static let shared = APIRequests()

    /// Promotions are rendered while the user waits, so requests fail fast instead of holding the screen for minutes.
    /// The same limits as the Android SDK.
    static func sessionConfiguration() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        // Longest wait for the connection or for the next bytes of the response
        configuration.timeoutIntervalForRequest = 15
        // Longest time for the whole request
        configuration.timeoutIntervalForResource = 30
        return configuration
    }

    private let session = URLSession(configuration: APIRequests.sessionConfiguration())

    func get(url: String, parameters: [String: String]) async throws -> Void {
        guard var urlComponents = URLComponents(string: url) else {
            throw CroboxError.invalidURL
        }
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard let finalURL = urlComponents.url else {
            throw CroboxError.invalidURL
        }

        var urlRequest = URLRequest(url: finalURL)
        urlRequest.setValue(UserAgent.value, forHTTPHeaderField: "User-Agent")

        let (_, response) = try await session.data(for: urlRequest)

        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw CroboxError.httpError(statusCode: httpResponse.statusCode)
        }
    }

    func post(url: URL, body: String) async throws -> Data {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = body.data(using: .utf8)
        urlRequest.setValue(UserAgent.value, forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: urlRequest)

        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw CroboxError.httpError(statusCode: httpResponse.statusCode)
        }

        return data
    }
}

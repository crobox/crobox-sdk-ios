
import Foundation

class APIRequests: NSObject {

    static let shared = APIRequests()

    func get(url: String, parameters: [String: String]) async throws -> Void {
        guard var urlComponents = URLComponents(string: url) else {
            throw CroboxErrors.invalidURL
        }
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard let finalURL = urlComponents.url else {
            throw CroboxErrors.invalidURL
        }

        var urlRequest = URLRequest(url: finalURL)
        urlRequest.timeoutInterval = 60 * 5

        let (_, response) = try await URLSession.shared.data(for: urlRequest)

        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw CroboxErrors.httpError(statusCode: httpResponse.statusCode)
        }
    }

    func post(url: URL, body: String) async throws -> Data {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = body.data(using: .utf8)
        urlRequest.timeoutInterval = 60 * 5

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw CroboxErrors.httpError(statusCode: httpResponse.statusCode)
        }

        return data
    }
}

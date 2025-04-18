
import Foundation

/// Represents an ongoing Campaign
public class Campaign: Codable {
    
    /// Campaign ID
    public let id: Int
    /// Campaign Name
    public let name: String
    /// Id of the Campaign Variant
    public let variantId: Int
    /// Name of the Campaign Variant
    public let variantName: String
    /// Indicates if variant is allocated to the control group
    public let control: Bool

    static func decode(from jsonData: Data) throws -> Campaign {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(Campaign.self, from: jsonData)
    }
}

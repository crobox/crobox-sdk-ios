
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

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = (try? container.decode(Int.self, forKey: .id)) ?? 0
        name = (try? container.decode(String.self, forKey: .name)) ?? ""
        variantId = (try? container.decode(Int.self, forKey: .variantId)) ?? 0
        variantName = (try? container.decode(String.self, forKey: .variantName)) ?? ""
        control = (try? container.decode(Bool.self, forKey: .control)) ?? false
    }

    static func decode(from jsonData: Data) throws -> Campaign {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(Campaign.self, from: jsonData)
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, variantId, variantName, control
    }
}

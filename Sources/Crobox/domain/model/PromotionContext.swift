
import Foundation

/// The context about campaigns
public class PromotionContext: NSObject, Decodable {
    
    /// List of campaign and variant names, combined
    public var groupName: String?
    /// Visitor ID
    public var visitorId: UUID
    /// Session ID
    public var sessionId: UUID
    /// The list of ongoing campaigns
    public var campaigns:[Campaign] = [Campaign]()
    
    private enum CodingKeys: String, CodingKey {
            case groupName
            case visitorId = "pid"
            case sessionId = "sid"
            case campaigns = "experiments"
        }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.groupName = try container.decodeIfPresent(String.self, forKey: .groupName)

        // Decode visitorId (UUID) or throw a custom error
        if let visitorIdStr = try? container.decode(String.self, forKey: .visitorId),
           let visitorId = UUID(uuidString: visitorIdStr) {
            self.visitorId = visitorId
        } else {
            throw CroboxErrors.invalidUUID(
                key: "context.visitorId",
                value: (try? container.decode(String.self, forKey: .visitorId)) ?? "nil"
            )
        }

        // Decode sessionId (UUID) or throw a custom error
        if let sessionIdStr = try? container.decode(String.self, forKey: .sessionId),
           let sessionId = UUID(uuidString: sessionIdStr) {
            self.sessionId = sessionId
        } else {
            throw CroboxErrors.invalidUUID(
                key: "context.sessionId",
                value: (try? container.decode(String.self, forKey: .sessionId)) ?? "nil"
            )
        }

        // Decode campaigns array, defaulting to an empty array if missing or invalid
        self.campaigns = (try? container.decode([Campaign].self, forKey: .campaigns)) ?? []
    }
}

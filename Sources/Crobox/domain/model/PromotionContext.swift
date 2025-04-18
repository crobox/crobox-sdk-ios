
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

        // Decode optional group name
        self.groupName = try container.decodeIfPresent(String.self, forKey: .groupName)

        // Decode visitorId (UUID)
        let visitorIdStr = try container.decode(String.self, forKey: .visitorId)
        guard let visitorId = UUID(uuidString: visitorIdStr) else {
            throw CroboxErrors.invalidUUID(key: "context.visitorId", value: visitorIdStr)
        }
        self.visitorId = visitorId

        // Decode sessionId (UUID)
        let sessionIdStr = try container.decode(String.self, forKey: .sessionId)
        guard let sessionId = UUID(uuidString: sessionIdStr) else {
            throw CroboxErrors.invalidUUID(key: "context.sessionId", value: sessionIdStr)
        }
        self.sessionId = sessionId

        // Decode campaigns array
        self.campaigns = try container.decode([Campaign].self, forKey: .campaigns)
    }
}

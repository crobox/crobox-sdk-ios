import Foundation

/// Represents a promotion calculated
public class Promotion: NSObject, Decodable {
    
    /// Unique id for this promotion
    public let id: UUID
    /// Product ID that this promotion was requested for
    public let productId: String?
    /// The variant which this promotion belongs to
    public let variantId: Int
    /// The campaign which this promotion belongs to
    public let campaignId: Int
    /// Promotion Content
    public let content: PromotionContent?

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Validate and decode `id` as UUID
        let idStr = try container.decode(String.self, forKey: .id)
        guard let id = UUID(uuidString: idStr) else {
            throw CroboxErrors.invalidUUID(key: "promotion.id", value: idStr)
        }
        self.id = id

        // Decode other properties
        self.productId = try container.decode(String.self, forKey: .productId)
        self.variantId = try container.decode(Int.self, forKey: .variantId)
        self.campaignId = try container.decode(Int.self, forKey: .campaignId)
        self.content = try container.decode(PromotionContent.self, forKey: .content)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case productId
        case variantId
        case campaignId
        case content
    }
}


import Foundation

/// Promotion Result
public class PromotionResponse: NSObject, Decodable {

    /// The context about campaigns
    public var context: PromotionContext
    /// The promotions calculated
    public var promotions = [Promotion]()

    private enum CodingKeys: String, CodingKey {
        case context
        case promotions
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode `context`
        self.context = try container.decode(PromotionContext.self, forKey: .context)

        // Decode `promotions`
        self.promotions = try container.decode([Promotion].self, forKey: .promotions)
    }
}

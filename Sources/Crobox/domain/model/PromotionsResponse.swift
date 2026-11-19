
import Foundation

/// Promotion Result
public class PromotionsResponse: NSObject, Decodable {

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

        // Decode `promotions`, skipping the ones that cannot be decoded instead of dropping all of them
        var promotions = [Promotion]()
        if var list = try? container.nestedUnkeyedContainer(forKey: .promotions) {
            while !list.isAtEnd {
                if let promotion = try? list.decode(Promotion.self) {
                    promotions.append(promotion)
                } else {
                    // Advance past the invalid element; stop if even that fails, to avoid looping forever
                    guard (try? list.decode(SkippedElement.self)) != nil else { break }
                }
            }
        }
        self.promotions = promotions
    }
}

/// Decodes any JSON value without reading it, to step over an element of an unkeyed container.
private struct SkippedElement: Decodable {
    init(from decoder: Decoder) throws {}
}

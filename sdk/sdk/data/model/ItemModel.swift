
import Foundation
public struct ItemModel {
    /*
     custom product id
     */
    public let id: String?
   
    /*
     product count which is added to the cart
     */
    public let qty: Int?

    public init(productId: String? = nil, quantity: Int? = nil) {
        self.id = productId
        self.qty = quantity
    }
}

//
//  ItemModel.swift
//  croboxSDK
//
//  Created by idris yıldız on 24.05.2024.
//

import Foundation
public struct ItemModel {
    /*
     custom product id
     */
    public let productId: Int?
   
    /*
     product count which is added to the cart
     */
    public let quantity: Int?

    public init(productId: Int? = nil, quantity: Int? = nil) {
        self.productId = productId
        self.quantity = quantity
    }
}

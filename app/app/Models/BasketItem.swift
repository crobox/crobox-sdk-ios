//
//  BasketItem.swift
//  CroboxTestApp
//
//  Created by Taras Teslyuk on 03.12.2024.
//

import Foundation

struct BasketItem: Identifiable, Hashable {
    var id = UUID()
    let title: String
    let image: String
    let price: Double
    var quantity: Int
}

extension Array where Element == BasketItem {
    func totalPrice() -> Double {
        reduce(0) { partialResult, item in
            item.price * Double(item.quantity) + partialResult
        }
    }
}

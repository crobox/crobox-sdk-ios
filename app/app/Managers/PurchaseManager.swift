//
//  PurchaseManager.swift
//  Crobox
//
//  Created by Taras Teslyuk on 09.12.2024.
//

import Foundation

final class PurchaseManager: ObservableObject {

    static let shared = PurchaseManager()

    @Published public var itemsInBasket: [Product] = []


    private init() { }

    func appendItem(_ title: String, quantity: Int) {
        for _ in 0..<quantity {
            itemsInBasket.append(sampleProducts.first { $0.title == title } ?? Product.mock())
        }
    }

    func removeOneItem(_ title: String) {
        guard !itemsInBasket.isEmpty else {
            return
        }

        if let index = itemsInBasket.lastIndex(where: { $0.title == title }) {
            itemsInBasket.remove(at: index)
        }
    }

    func removeAllSameItems(_ title: String) {
        guard !itemsInBasket.isEmpty else {
            return
        }

        itemsInBasket = itemsInBasket.filter { $0.title != title }
    }

    func removeAllItems() {
        itemsInBasket.removeAll()
    }
}

struct ProductKey: Hashable {
    let title: String
    let imageName: String
}

extension Array where Element == Product {
    func toBasketItems() -> [BasketItem] {
        let grouped = Dictionary(grouping: self) { product in
            ProductKey(title: product.title, imageName: product.imageName)
        }

        return grouped.map { key, products in
            let totalPrice = products.reduce(0) { $0 + $1.price }
            let totalQuantity = products.count
            return BasketItem(
                title: key.title,
                image: key.imageName,
                price: totalPrice,
                quantity: totalQuantity
            )
        }
    }
}

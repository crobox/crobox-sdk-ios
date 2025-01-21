//
//  Product.swift
//  CroboxTestApp
//
//  Created by Taras Teslyuk on 25.11.2024.
//

import Foundation

struct Product: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let category: String
    let price: Double
    let imageName: String
    let sizes: [Int]
    let isOnSale: Bool
    let isOutlet: Bool

    static func mock() -> Self {
        Product(
            title: "Handcrafted Metal Ball",
            category: "Handmade",
            price: 551.0,
            imageName: "laptop1",
            sizes: [35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45],
            isOnSale: true,
            isOutlet: true
        )
    }
}

extension Array where Element == Product {
    func filterBy(text: String) -> [Element] {
        if text.isEmpty { return self }
        
        return self.filter { $0.title.lowercased().contains(text.lowercased()) }
    }
 }

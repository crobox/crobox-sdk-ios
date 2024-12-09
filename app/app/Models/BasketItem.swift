//
//  BasketItem.swift
//  CroboxTestApp
//
//  Created by Taras Teslyuk on 03.12.2024.
//

import Foundation

struct BasketItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let image: String
    let price: Double
    var quantity: Int
}

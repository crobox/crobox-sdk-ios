//
//  ProductCardView.swift
//  TestUICrobox
//
//  Created by Taras Teslyuk on 19.11.2024.
//

import Foundation
import SwiftUI

// MARK: - Main Content View
struct ProductGridView: View {
    @EnvironmentObject private var navigationManager: NavigationManager

    let products: [Product] = sampleProducts

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack(path: $navigationManager.navPath) {
            ScrollView {
                HStack(spacing: 8) {
                    SearchBarWithCartView()
                    Button(action: {
                        navigationManager.append(.basket)
                    }) {
                        Image(systemName: "cart.fill")
                            .foregroundColor(.black)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    }
                }
                .padding()

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(products) { product in
                        ProductCardView(product: product)
                            .onTapGesture {
                                CroboxEventManager.shared.onClickEvent(product)
                                navigationManager.append(.detail(product))
                            }
                    }
                }
                .padding()
            }
            .screenNavigation()
            .navigationTitle("Crobox Demo App")
        }
        .onAppear {
            CroboxEventManager.shared.onPageViewEvent(pageName: "product-list")
        }
    }

}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ProductGridView()
    }
}

// MARK: - Sample Data
let sampleProducts = [
    Product(
        title: "Handcrafted Metal Laptop",
        category: "Handmade",
        price: 551.0,
        imageName: getTestImageUrl(1),
        sizes: [35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45],
        isOnSale: false,
        isOutlet: false
    ),
    Product(
        title: "Handmade Rubber Laptop",
        category: "Handmade",
        price: 532.0,
        imageName: getTestImageUrl(2),
        sizes: [35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45],
        isOnSale: false,
        isOutlet: false)
    ,
    Product(
        title: "Ergonomic Soft Table",
        category: "Rustic",
        price: 494.0,
        imageName: getTestImageUrl(3),
        sizes: [35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45],
        isOnSale: true,
        isOutlet: true
    ),
    Product(
        title: "Gorgeous Wooden Screen",
        category: "Practical",
        price: 520.0,
        imageName: getTestImageUrl(4),
        sizes: [35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45],
        isOnSale: false,
        isOutlet: false
    )
]


func getTestImageUrl(_ id: Int) -> String {
    return "https://picsum.photos/id/\(id)/200/200"
}


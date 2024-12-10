//
//  BasketView.swift
//  TestUICrobox
//
//  Created by Taras Teslyuk on 19.11.2024.
//

import Foundation
import SwiftUI

struct BasketView: View {

    @EnvironmentObject private var navigationManager: NavigationManager
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var purchaseManager = PurchaseManager.shared

    @State private var basketItems: [BasketItem] = []

    var totalPrice: Double {
        basketItems.reduce(0) { $0 + $1.price * Double($1.quantity) }
    }

    var body: some View {
        NavigationStack(path: $navigationManager.navPath) {
            VStack {
                navigationBar

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(basketItems) { item in
                            BasketItemView(item: item)
                        }
                    }
                    .padding(.horizontal)
                }
                
                BottomMenuView(totalAmount: totalPrice, items: basketItems, onPurchase: {
                    navigationManager.append(.purchase(basketItems))
                })
            }
            .background(Color(UIColor.systemGray6))
            .navigationBarHidden(true)
            .screenNavigation()
            .onAppear {
                basketItems = purchaseManager.itemsInBasket.toBasketItems().sorted { $0.title > $1.title }
            }
            .onChange(of: purchaseManager.itemsInBasket) { _, _ in
                basketItems = purchaseManager.itemsInBasket.toBasketItems().sorted { $0.title > $1.title }
            }
        }
        .onAppear {
            CroboxEventManager.shared.onPageViewEvent(pageName: "basket")
        }
    }

    private var navigationBar: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.black)
            }
            .padding()

            Text("My Basket")
                .font(.title3)
                .fontWeight(.bold)

            Spacer()
        }
        .background(Color.white)
        .padding(.bottom, 4)
    }
}

struct BasketItemView: View {
    @ObservedObject private var purchaseManager = PurchaseManager.shared
    var item: BasketItem

    var body: some View {
        HStack {
            // Product Image
            HStack {
                AsyncCachedImage(url: URL(string: item.image)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)

                } placeholder: {
                    ProgressView()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(item.title)
                    .font(.headline)

                HStack {
                    // Decrease Quantity
                    Button(action: {
                        if item.quantity > 1 {
                            purchaseManager.removeOneItem(item.title)
                            CroboxEventManager.shared.onRemoveFromCartEvent(item.id, price: item.price, quantity: 1)
                        }
                    }) {
                        Text("-")
                            .font(.title2)
                            .frame(width: 40, height: 40)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }

                    // Quantity Display
                    Text("\(item.quantity)")
                        .font(.title2)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .cornerRadius(8)

                    // Increase Quantity
                    Button(action: {
                        purchaseManager.appendItem(item.title, quantity: 1)
                        CroboxEventManager.shared.onAddToCartEvent(item.id, price: item.price, quantity: 1)
                    }) {
                        Text("+")
                            .font(.title2)
                            .frame(width: 40, height: 40)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            }
            Spacer()

            // Price
            Text(String(format: "$ %.2f", item.price))
                .font(.title3)

            Button(action: {
                purchaseManager.removeAllSameItems(item.title)
                CroboxEventManager.shared.onRemoveFromCartEvent(item.id, price: item.price, quantity: item.quantity)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .frame(width: 40, height: 40)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

struct BottomMenuView: View {
    var totalAmount: Double
    var items: [BasketItem]
    var onPurchase: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Total:")
                    .font(.headline)
                Spacer()
                Text(String(format: "$ %.2f", totalAmount))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)

            Button(action: {
                CroboxEventManager.shared.onCheckoutEvent(items)
                onPurchase()
            }) {
                Text("PURCHASE")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -2)
    }
}

struct BasketView_Previews: PreviewProvider {
    static var previews: some View {
        BasketView()
    }
}

extension URLCache {

    static let imageCache = URLCache(memoryCapacity: 512*1000*1000, diskCapacity: 10*1000*1000*1000)
}

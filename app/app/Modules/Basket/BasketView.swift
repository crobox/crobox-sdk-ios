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
    
    @StateObject private var purchaseManager = PurchaseManager.shared

    @State private var basketItems: [BasketItem] = []

    private var totalPrice: Double { basketItems.totalPrice() }

    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            products
            menu
        }
        .background(Color(UIColor.systemGray6))
        .navigationBarHidden(true)
        .animation(.linear(duration: 0.12), value: basketItems.count)
        .onAppear {
            basketItems = purchaseManager.itemsInBasket.toBasketItems().sorted { $0.title > $1.title }
            CroboxEventManager.shared.onPageViewEvent(pageName: "basket")
        }
        .onChange(of: purchaseManager.itemsInBasket) { _, _ in
            basketItems = purchaseManager.itemsInBasket.toBasketItems().sorted { $0.title > $1.title }
        }
    }

    private var navigationBar: some View {
        HeaderView(
            title: "My Basket",
            onBack: dismiss.callAsFunction
        )
    }
    
    private var products: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                ForEach(basketItems) { item in
                    BasketItemView(item: item)
                }
            }
            .onChange(of: basketItems.map(\.id)) { oldValue, newValue in
                print("New ids appeared: \(newValue)")
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
    }
    
    private var menu: some View {
        BottomMenuView(totalAmount: totalPrice) {
            CroboxEventManager.shared.onCheckoutEvent(basketItems)
            navigationManager.append(.purchase(basketItems))
        }
    }
}

fileprivate struct BasketItemView: View {
    let item: BasketItem

    var body: some View {
        HStack(spacing: 8) {
            image
            
            VStack(alignment: .leading, spacing: 4) {
                title
                HStack(spacing: 12) {
                    quantity
                    price.frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            
            delete
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
    
    private var image: some View {
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
    
    private var title: some View {
        Text(item.title)
            .font(.headline)

    }
    
    private var quantity: some View {
        QuantityView(item: item)
    }
    
    private var price: some View {
        Text(String(format: "$ %.2f", item.price))
            .font(.title3)
            .lineLimit(1)
            .minimumScaleFactor(0.1)
    }
    
    private var delete: some View {
        Button {
            PurchaseManager.shared.removeAllSameItems(item.title)
            CroboxEventManager.shared.onRemoveFromCartEvent(item.id, price: item.price, quantity: item.quantity)
        } label: {
            Image(systemName: "trash")
                .foregroundColor(.red)
                .frame(width: 40, height: 40)
        }
    }
}

fileprivate struct QuantityView: View {
    let item: BasketItem
    
    var body: some View {
        HStack(spacing: 0) {
            controlButton(increment: false)
            title
            controlButton(increment: true)
        }
    }
    
    private var title: some View {
        Text("\(item.quantity)")
            .font(.title2)
            .frame(width: 40, height: 40)
            .foregroundColor(.black)
            .background(Color.white)
            .cornerRadius(8)
    }
    
    private func controlButton(increment: Bool) -> some View {
        Button {
            if increment {
                PurchaseManager.shared.appendItem(item.title, quantity: 1)
                CroboxEventManager.shared.onAddToCartEvent(item.id, price: item.price, quantity: 1)
            } else {
                PurchaseManager.shared.removeOneItem(item.title)
                CroboxEventManager.shared.onRemoveFromCartEvent(item.id, price: item.price, quantity: 1)
            }
        } label: {
            Text(increment ? "+" : "-")
                .font(.title2)
                .frame(width: 40, height: 40)
                .foregroundColor(.black)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
        }
        .disabled(increment ? false : item.quantity <= 1)
    }
}


struct BottomMenuView: View {
    let totalAmount: Double
    let onPurchase: () -> ()

    var body: some View {
        VStack(spacing: 16) {
            total
            purchaseButton
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -2)
    }
    
    private var total: some View {
        HStack {
            Text("Total:")
                .font(.headline)
            Spacer()
            Text(String(format: "$ %.2f", totalAmount))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.gray)
        }
    }
    
    private var purchaseButton: some View {
        Button {
            onPurchase()
        } label: {
            Text("PURCHASE")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(Color.blue)
                .cornerRadius(8)
        }
    }
}

struct BasketView_Previews: PreviewProvider {
    static var previews: some View {
        BasketView()
    }
}

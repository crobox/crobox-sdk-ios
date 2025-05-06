//
//  CompletePurchaseView.swift
//  TestUICrobox
//
//  Created by Taras Teslyuk on 19.11.2024.
//

import Foundation
import SwiftUI

struct CompletePurchaseView: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var purchaseManager = PurchaseManager.shared

    @State var purchasedItems: [BasketItem]

    private var totalPrice: Double { purchasedItems.totalPrice() }

    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            items
            menu
        }
        .background(Color(UIColor.systemGray6))
        .navigationBarHidden(true)
        .onAppear {
            CroboxEventManager.shared.onPageViewEvent(pageName: "purchase")
        }
    }

    private var navigationBar: some View {
        HeaderView(
            title: "Complete Purchase",
            onBack: dismiss.callAsFunction
        )
    }
    
    private var items: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(purchasedItems) { item in
                    ItemCell(item: item)
                }
            }
            .padding()
        }
    }
    
    private var menu: some View {
        BottomMenuView(totalAmount: totalPrice) {
            CroboxEventManager.shared.onPurchaseEvent(purchasedItems)
            print("Purchase confirmed with total: $\(totalPrice)")
            purchasedItems.removeAll()
            purchaseManager.removeAllItems()
        }
    }
}

fileprivate struct ItemCell: View {
    let item: BasketItem
    
    var body: some View {
        HStack {
            title
            quantity
            price
        }
    }
    
    private var title: some View {
        Text(item.title)
            .font(.subheadline)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var quantity: some View {
        Text("\(item.quantity)")
            .font(.subheadline)
            .frame(width: 20, alignment: .trailing)
    }
    
    private var price: some View {
        Text(String(format: "$ %.2f", item.price))
            .font(.subheadline)
            .frame(width: 80, alignment: .trailing)
    }
}

//
//  CompletePurchaseView.swift
//  TestUICrobox
//
//  Created by Taras Teslyuk on 19.11.2024.
//

import Foundation
import SwiftUI

struct CompletePurchaseView: View {

    @EnvironmentObject private var navigationManager: NavigationManager
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var purchaseManager = PurchaseManager.shared

    @State var purchasedItems: [BasketItem]

    var totalPrice: Double {
        purchasedItems.reduce(0) { $0 + $1.price * Double($1.quantity) }
    }

    var body: some View {
        NavigationStack(path: $navigationManager.navPath) {
            VStack {
                navigationBar

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(purchasedItems) { item in
                            HStack {
                                Text(item.title)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                Spacer()
                                // Quantity
                                Text("\(item.quantity)")
                                    .font(.subheadline)
                                    .frame(width: 20, alignment: .trailing)
                                // Price
                                Text(String(format: "$ %.2f", item.price))
                                    .font(.subheadline)
                                    .frame(width: 80, alignment: .trailing)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                VStack(spacing: 16) {
                    HStack {
                        Text("Total:")
                            .font(.headline)
                        Spacer()
                        Text(String(format: "$ %.2f", totalPrice))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)

                    Button(action: {
                        purchasedItems.removeAll()
                        purchaseManager.removeAllItems()
                        print("Purchase confirmed with total: $\(totalPrice)")
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
            .background(Color(UIColor.systemGray6))
            .navigationBarHidden(true)
            .screenNavigation()
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

            Text("Complete Purchase")
                .font(.title3)
                .fontWeight(.bold)

            Spacer()
        }
        .background(Color.white)
        .padding(.bottom, 4)
    }
}

//
//  ProductDetailsView.swift
//  TestUICrobox
//
//  Created by Taras Teslyuk on 19.11.2024.
//

import Foundation
import SwiftUI

struct ProductDetailsView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var purchaseManager = PurchaseManager.shared

    @State private var quantity: Int = 1
    @State private var selectedSize: Int? = nil

    let product: Product

    var body: some View {
        NavigationStack(path: $navigationManager.navPath) {
            VStack(alignment: .leading) {
                navigationBar

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        imageHeader
                        productDetails
                        quantitySelector
                        sizes
                        purchaseButton
                    }
                }
            }
            .screenNavigation()
            .background(Color(UIColor.systemGray6))
            .navigationBarHidden(true)
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

            Text("Product Details")
                .font(.headline)
                .foregroundColor(.black)

            Spacer()
        }
        .background(Color.white)
        .padding(.bottom, 4)
    }

    private var imageHeader: some View {
        Group {
            AsyncCachedImage(url: URL(string: product.imageName)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .cornerRadius(0)
            } placeholder: {
                ProgressView()
                    .frame(height: 200)
                    .cornerRadius(0)
            }

            HStack(spacing: 8) {
                ForEach(1...3, id: \.self) { index in
                    AsyncCachedImage(url: URL(string: product.imageName)) { image in
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
            }
            .padding(.horizontal)
        }
    }

    private var productDetails: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {

                Text(product.title)
                    .font(.title2)
                    .fontWeight(.bold)

                HStack {
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < 4 ? "star.fill" : "star.lefthalf.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        }
                    }
                    Text("4.5")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(product.category)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            Spacer()
        }
    }

    private var quantitySelector: some View {
        HStack {
            Text("Quantity:")
                .font(.subheadline)

            HStack(spacing: 0) {
                Button(action: {
                    if quantity > 1 { quantity -= 1 }
                }) {
                    Text("-")
                        .font(.title2)
                        .frame(width: 40, height: 40)
                        .foregroundColor(.black)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }

                Text("\(quantity)")
                    .font(.title2)
                    .frame(width: 40, height: 40)
                    .foregroundColor(.black)
                    .background(Color.white)
                    .cornerRadius(8)

                Button(action: {
                    quantity += 1
                }) {
                    Text("+")
                        .font(.title2)
                        .frame(width: 40, height: 40)
                        .foregroundColor(.black)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }

            Spacer()

            Text(String(format: "$ %.2f", product.price * Double(quantity)))
                .font(.title2)
                .fontWeight(.bold)
        }
        .padding(.horizontal)
    }

    private var sizes: some View {
        VStack(alignment: .leading) {
            Text("Available sizes")
                .font(.subheadline)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                ForEach(product.sizes, id: \.self) { size in
                    Button(action: {
                        selectedSize = size
                    }) {
                        Text("\(size)")
                            .font(.headline)
                            .foregroundColor(selectedSize == size ? .white : .black)
                            .frame(width: 50, height: 40)
                            .background(selectedSize == size ? Color.blue : Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private var purchaseButton: some View {
        Button(action: {
            purchaseManager.appendItem(product.title, quantity: quantity)
        }) {
            Text("ADD TO BASKET")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color.blue)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .padding()
    }
}

struct ProductDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailsView(product: Product.mock())
    }
}

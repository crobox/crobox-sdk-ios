//
//  ProductDetailsView.swift
//  TestUICrobox
//
//  Created by Taras Teslyuk on 19.11.2024.
//

import Foundation
import SwiftUI

struct ProductDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var purchaseManager = PurchaseManager.shared

    @State private var quantity: Int = 1
    @State private var selectedSize: Int? = nil

    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    imageHeader
                    productDetails
                    quantitySelector
                    sizes
                }
                .padding(.horizontal, 16)
            }
            
            purchaseButton
        }
        .background(Color(UIColor.systemGray6))
        .navigationBarHidden(true)
        .onAppear {
            CroboxEventManager.shared.onPageViewEvent(pageName: "product-details")
        }
    }

    private var navigationBar: some View {
        HeaderView(
            title: "Product Details",
            onBack: dismiss.callAsFunction
        )
    }

    private var imageHeader: some View {
        VStack(spacing: 8) {
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
        }
        .padding(.horizontal, -16)
    }

    private var productDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(product.title)
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 8) {
                StarRatingView(rating: 4.5)
                
                Text("4.5")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(product.category)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var quantitySelector: some View {
        HStack {
            Text("Quantity:")
                .font(.subheadline)

            QuantityView(quantity: $quantity, product: product)

            Spacer()

            Text(String(format: "$ %.2f", product.price * Double(quantity)))
                .font(.title2)
                .fontWeight(.bold)
        }
    }

    private var sizes: some View {
        VStack(alignment: .leading) {
            Text("Available sizes")
                .font(.subheadline)
            
            let items: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)
            LazyVGrid(columns: items, spacing: 12) {
                ForEach(product.sizes, id: \.self) { size in
                    let isSelected = selectedSize == size
                    
                    Button {
                        selectedSize = size
                    } label: {
                        SizeCell(size: size, isSelected: isSelected)
                    }
                }
            }
        }
    }

    private var purchaseButton: some View {
        Button {
            purchaseManager.appendItem(product.title, quantity: quantity)
        } label: {
            Text("ADD TO BASKET")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color.blue)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

fileprivate struct StarRatingView: View {
    let rating: Double

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { index in
                if rating >= Double(index) {
                    Image(systemName: "star.fill")
                } else if rating >= Double(index) - 0.5 {
                    Image(systemName: "star.leadinghalf.filled")
                } else {
                    Image(systemName: "star")
                }
            }
        }
        .foregroundColor(.yellow)
        .font(.caption)
    }
}

fileprivate struct QuantityView: View {
    @Binding var quantity: Int
    let product: Product
    
    var body: some View {
        HStack(spacing: 0) {
            controlButton(increment: false)
            title
            controlButton(increment: true)
        }
    }
    
    private var title: some View {
        Text("\(quantity)")
            .font(.title2)
            .frame(width: 40, height: 40)
            .foregroundColor(.black)
            .background(Color.white)
            .cornerRadius(8)
    }
    
    private func controlButton(increment: Bool) -> some View {
        Button {
            if increment {
                quantity += 1
                CroboxEventManager.shared.onAddToCartEvent(product, quantity: 1)
            } else {
                quantity = max(1, quantity - 1)
                CroboxEventManager.shared.onRemoveFromCartEvent(product, quantity: 1)
            }
        } label: {
            Text(increment ? "+" : "-")
                .font(.title2)
                .frame(width: 40, height: 40)
                .foregroundColor(.black)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
        }
        .disabled(increment ? false : quantity <= 1)
    }
}

fileprivate struct SizeCell: View {
    let size: Int
    let isSelected: Bool
    
    var body: some View {
        let foregroundColor = isSelected ? Color.white : Color.black
        let background = isSelected ? Color.blue : Color.gray.opacity(0.2)
        
        Text("\(size)")
            .font(.headline)
            .foregroundColor(foregroundColor)
            .frame(width: 50, height: 40)
            .background(background)
            .cornerRadius(8)
    }
}

struct ProductDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailsView(product: Product.mock())
    }
}

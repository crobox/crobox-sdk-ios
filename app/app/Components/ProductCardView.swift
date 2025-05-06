//
//  ProductCardView.swift
//  TestUICrobox
//
//  Created by Taras Teslyuk on 03.12.2024.
//

import SwiftUI

struct ProductCardView: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                image
                promotion
            }
            productDetails
        }
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
    
    private var image: some View {
        AsyncCachedImage(url: URL(string: product.imageName)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 120)
                .cornerRadius(8)
        } placeholder: {
            ProgressView()
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .cornerRadius(8)
        }
    }
    
    private var promotion: some View {
        HStack {
            if product.isOnSale {
                BadgeView(text: "SALE", color: .red)
            }
            
            if product.isOutlet {
                BadgeView(text: "OUTLET", color: .green)
            }
        }
        .padding([.top, .leading], 4)
    }
    
    private var productDetails: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(product.title)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Text(product.category)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
            
            Text(String(format: "$ %.1f", product.price))
                .font(.title3)
                .bold()
                .multilineTextAlignment(.leading)
        }
        .padding([.horizontal, .bottom], 8)
    }
}

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
                
                AsyncCachedImage(url: URL(string: product.imageName)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .cornerRadius(8)
                } placeholder: {
                    ProgressView()
                        .frame(height: 120)
                        .cornerRadius(8)
                }

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
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.headline)
                    .lineLimit(2)
                Text(product.category)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(String(format: "$ %.1f", product.price))
                    .font(.title3)
                    .bold()
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

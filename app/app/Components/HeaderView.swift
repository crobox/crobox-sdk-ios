//
//  HeaderView.swift
//  CroboxTestApp
//
//  Created by Ruslan Duda on 21.01.2025.
//

import SwiftUI

struct HeaderView: View {
    let title: String
    let onBack: () -> ()
    
    var body: some View {
        HStack(spacing: 32) {
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.black)
            }

            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.white)
    }
}

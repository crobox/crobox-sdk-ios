//
//  SearchBarWithCartView.swift
//  CroboxTestApp
//
//  Created by Taras Teslyuk on 03.12.2024.
//

import Foundation
import SwiftUI

struct SearchBarWithCartView: View {
    @State private var searchText: String = "" // State to store search text

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass") // Search icon
                .foregroundColor(.gray)
            TextField("Search...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle()) // Plain style to customize appearance
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray, lineWidth: 1) // Border styling
        )
    }
}

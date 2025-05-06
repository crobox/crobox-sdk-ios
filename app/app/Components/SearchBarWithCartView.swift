//
//  SearchBarWithCartView.swift
//  CroboxTestApp
//
//  Created by Taras Teslyuk on 03.12.2024.
//

import Foundation
import SwiftUI

struct SearchBarWithCartView: View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            magnifyingglassIcon
            textfield
            xmark
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
    
    private var magnifyingglassIcon: some View {
        Image(systemName: "magnifyingglass")
            .foregroundColor(.gray)
    }
    
    private var textfield: some View {
        TextField("Search...", text: $searchText)
            .textFieldStyle(PlainTextFieldStyle())
    }
    
    private var xmark: some View {
        Button {
            searchText = ""
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        } label: {
            Image(systemName: "xmark")
                .foregroundColor(.gray)
                .padding(5)
                .contentShape(Rectangle())
                .padding(-5)
        }
        .opacity(searchText.isEmpty ? 0 : 1)
    }
}

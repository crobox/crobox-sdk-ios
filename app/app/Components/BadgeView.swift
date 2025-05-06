//
//  BadgeView.swift
//  TestUICrobox
//
//  Created by Taras Teslyuk on 03.12.2024.
//

import SwiftUI

struct BadgeView: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption)
            .bold()
            .foregroundColor(.white)
            .padding(4)
            .background(color)
            .cornerRadius(4)
    }
}

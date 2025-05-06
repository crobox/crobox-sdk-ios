//
//  RootView.swift
//  Crobox
//
//  Created by Taras Teslyuk on 09.12.2024.
//

import SwiftUI

struct RootView: View {
    @StateObject private var navigationManager = NavigationManager()

    var body: some View {
        ProductGridView()
            .environmentObject(navigationManager)
    }
}

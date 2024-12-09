//
//  NavigationManager.swift
//  Crobox
//
//  Created by Taras Teslyuk on 09.12.2024.
//

import SwiftUI

enum ScreenNavigation: Hashable {
    case detail(Product)
    case basket
    case purchase([BasketItem])
}

final class NavigationManager: ObservableObject {

    @Published public var navPath = NavigationPath()

    public func append(_ screen: ScreenNavigation) {
        navPath.append(screen)
    }
}

extension View {
    func screenNavigation() -> some View { self
        .navigationDestination(for: ScreenNavigation.self) { screen in
            switch screen {
            case .detail(let product):
                ProductDetailsView(product: product)
            case .basket:
                BasketView()
            case .purchase(let basketItems):
                CompletePurchaseView(purchasedItems: basketItems)
            }
        }
    }
}

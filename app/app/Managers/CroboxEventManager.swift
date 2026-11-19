//
//  CroboxEventManager.swift
//  CroboxTestApp
//
//  Created by Taras Teslyuk on 02.12.2024.
//

import Foundation
import Crobox

// Singleton EventManager class
class CroboxEventManager {
    static let shared = CroboxEventManager()

    private init() {
        setupCrobox()
    }
    
    /// ViewContext contains view specific parameters, shared by all event and promotion requests sent from the same view.
    /// It must be re-created when the user visits a view, eg. the cart,
    let overviewView = ViewContext(viewId: UUID(), viewType: .overview, customProperties: ["test":"test"])

    /// Crobox Configuration Setup
    private func setupCrobox() {
        let containerId = "xlrc9t"
        
        // Initialize Crobox configuration
        let config = CroboxConfig(
            containerId: containerId,
            visitorId: CroboxVisitor.visitorId(),
            localeCode: LocaleCode("en_US")
        )

        Crobox.shared.configure(config)
        
        /// Enable/Disable debugging
        Crobox.shared.isLoggingEnabled = true
        
        
        print("Crobox initialized with containerId: \(containerId)")
    }
    
    func onClickEvent(_ product: Product) {
        /// Sending Click events with optional event specific parameters
        let clickParams = ClickParams(productId: product.id.uuidString, quantity: 1)
        Crobox.shared.clickEvent(view: overviewView, params: clickParams)
    }
    
    func onAddToCartEvent(_ product: Product, quantity: Int) {
        /// Sending Add To Cart events with optional event specific parameters
        let addToCartParams = CartParams(productId: product.id.uuidString, quantity: 1)
        Crobox.shared.addToCartEvent(view: overviewView, params: addToCartParams)
    }
    
    func onAddToCartEvent(_ id: UUID, quantity: Int) {
        /// Sending Add To Cart events with optional event specific parameters
        let addToCartParams = CartParams(productId: id.uuidString, quantity: 1)
        Crobox.shared.addToCartEvent(view: overviewView, params: addToCartParams)
    }
    
    func onRemoveFromCartEvent(_ product: Product, quantity: Int) {
        /// Sending Remove From Cart events with optional event specific parameters
        let removeFromCartParams = CartParams(productId: product.id.uuidString, quantity: 1)
        Crobox.shared.removeFromCartEvent(view: overviewView, params: removeFromCartParams)
    }
    
    func onRemoveFromCartEvent(_ id: UUID, quantity: Int) {
        /// Sending Remove From Cart events with optional event specific parameters
        let removeFromCartParams = CartParams(productId: id.uuidString, quantity: 1)
        Crobox.shared.removeFromCartEvent(view: overviewView, params: removeFromCartParams)
    }
    
    func onErrorEvent() {
        /// Sending Error events with optional event specific parameters
        let errorParams = ErrorParams(tag: "ParsingError", name: "IllegalArgumentException", message: "bad input")
        Crobox.shared.errorEvent(view: overviewView, params: errorParams)
    }
    
    func onViewEvent(title: String) {
        /// Sending view event
        let viewParams = ViewParams(
            title: title,
            product: ProductParams(productId: "1", list: "related products"),
            searchTerms: "some search terms",
            impressions: [
                ProductParams(productId: "5"),
                ProductParams(productId: "8")
            ],
            customProperties: ["event-specific": "value1", "event-specific2": "value2"]
        )
        Crobox.shared.viewEvent(view: overviewView, params: viewParams)
    }
    
    // Function to convert [BasketItem] -> [ProductParams]
    func convertToProductParams(items: [BasketItem]) -> [ProductParams] {
        return items.map { ProductParams(productId: $0.id.uuidString, quantity: $0.quantity) }
    }
    
    func onCheckoutEvent(_ items: [BasketItem]) {
        /// Sending checkout event
        let checkoutView = ViewContext(viewId: UUID(), viewType: .checkout, customProperties: ["checkout-specific":"yes"])
        
        let checkoutParams = CheckoutParams(
            products: convertToProductParams(items: items),
            step: "1",
            customProperties: ["page-specific-key":"value1"]
        )
        Crobox.shared.checkoutEvent(view: checkoutView, params: checkoutParams)
    }
    
    func onPurchaseEvent(_ items: [BasketItem]) {
        /// Sending purchase event
        let completeView = ViewContext(viewId: UUID(), viewType: .complete, customProperties: ["complete-specific":"yes"])
        
        let purchaseParams = PurchaseParams(
            products: convertToProductParams(items: items),
            transactionId: "trx-id-1",
            affiliation: "some online store",
            coupon: "discount 1",
            revenue: 5.0,
            customProperties: ["event-specific": "value and value2"]
        )
        Crobox.shared.purchaseEvent(view: completeView, params: purchaseParams)
    }

}

//
//  CroboxEventManager.swift
//  CroboxTestApp
//
//  Created by Taras Teslyuk on 02.12.2024.
//

import Foundation
import croboxSDK

// Singleton EventManager class
class CroboxEventManager {
    static let shared = CroboxEventManager()

    private init() {
        setupCrobox()
    }
    
    /// RequestQueryParams contains page specific parameters, shared by all event and promotion requests sent from the same page/view.
    /// Request params must be re-created when user visits a page/view, eg. CartPage,
    let overviewPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageOverview, customProperties: ["test":"test"])

    /// Crobox Configuration Setup
    private func setupCrobox() {
        let containerId = "xlrc9t"
        
        // Initialize Crobox configuration
        let config = CroboxConfig(
            containerId: containerId,
            visitorId: UUID(),
            localeCode: .en_US
        )

        Crobox.shared.initConfig(config: config)
        
        /// Enable/Disable debugging
        Crobox.shared.isDebug = true
        
        
        print("Crobox initialized with containerId: \(containerId)")
    }
    
    func onClickEvent(_ product: Product) {
        /// Sending Click events with optional event specific parameters
        let clickQueryParams = ClickQueryParams(productId: product.id.uuidString, price: product.price, quantity: 1)
        Crobox.shared.clickEvent(queryParams: overviewPageParams, clickQueryParams: clickQueryParams)
    }
    
    func onAddToCartEvent(_ product: Product, quantity: Int) {
        /// Sending Add To Cart events with optional event specific parameters
        let addCartQueryParams = CartQueryParams(productId: product.id.uuidString, price: product.price, quantity: 1)
        Crobox.shared.addCartEvent(queryParams: overviewPageParams, addCartQueryParams:addCartQueryParams)
    }
    
    func onAddToCartEvent(_ id: UUID, price: Double, quantity: Int) {
        /// Sending Add To Cart events with optional event specific parameters
        let addCartQueryParams = CartQueryParams(productId: id.uuidString, price: price, quantity: 1)
        Crobox.shared.addCartEvent(queryParams: overviewPageParams, addCartQueryParams:addCartQueryParams)
    }
    
    func onRemoveFromCartEvent(_ product: Product, quantity: Int) {
        /// Sending Remove From Cart events with optional event specific parameters
        let rmCartQueryParams = CartQueryParams(productId: product.id.uuidString, price: product.price, quantity: 1)
        Crobox.shared.removeCartEvent(queryParams: overviewPageParams, rmCartQueryParams: rmCartQueryParams)
    }
    
    func onRemoveFromCartEvent(_ id: UUID, price: Double, quantity: Int) {
        /// Sending Remove From Cart events with optional event specific parameters
        let rmCartQueryParams = CartQueryParams(productId: id.uuidString, price: price, quantity: 1)
        Crobox.shared.removeCartEvent(queryParams: overviewPageParams, rmCartQueryParams: rmCartQueryParams)
    }
    
    func onErrorEvent() {
        /// Sending Error events with optional event specific parameters
        let errorParams = ErrorQueryParams(tag: "ParsingError", name: "IllegalArgumentException", message: "bad input")
        Crobox.shared.errorEvent(queryParams: overviewPageParams, errorQueryParams: errorParams)
    }
    
    func onPageViewEvent(pageName: String) {
        /// Sending page view event
        let pageViewParams = PageViewParams(
            pageTitle: pageName,
            product: ProductParams(productId: "1", price: 1.0, otherProductIds: ["2", "3", "4"]),
            searchTerms: "some search terms",
            impressions: [
                ProductParams(productId: "5"),
                ProductParams(productId: "8")
            ],
            customProperties: ["event-specific": "value1", "event-specific2": "value2"]
        )
        Crobox.shared.pageViewEvent(queryParams: overviewPageParams, pageViewParams: pageViewParams)
    }
    
    // Function to convert [BasketItem] -> [ProductParams]
    func convertToProductParams(items: [BasketItem]) -> [ProductParams] {
        return items.map { ProductParams(productId: $0.id.uuidString) }
    }
    
    func onCheckoutEvent(_ items: [BasketItem]) {
        /// Sending checkout event
        let checkoutPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageCheckout, customProperties: ["checkout-specific":"yes"])
        
        let checkoutParams = CheckoutParams(
            products: convertToProductParams(items: items),
            step: "step-1",
            customProperties: ["page-specific-key":"value1"]
        )
        Crobox.shared.checkoutEvent(queryParams: checkoutPageParams, checkoutParams: checkoutParams)
    }
    
    func onPurchaseEvent(_ items: [BasketItem]) {
        /// Sending purchase event
        let pageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageComplete, customProperties: ["complete-specific":"yes"])
        
        let purchaseParams = PurchaseParams(
            products: convertToProductParams(items: items),
            transactionId: "trx-id-1",
            affiliation: "some online store",
            coupon: "discount 1",
            revenue: 5.0,
            customProperties: ["event-specific": "value and value2"]
        )
        Crobox.shared.purchaseEvent(queryParams: pageParams, purchaseParams: purchaseParams)
    }

}

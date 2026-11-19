//
//  ViewController.swift
//  CroboxTestApp
//
//  Created by idris yıldız on 5.06.2024.
//

import UIKit
import Crobox

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let containerId = "xlrc9t"
        let productIds = ["1", "2", "3"]
        
        //Crobox.shared is the single point of contact for all interactions, keeping the configuration and providing all functionality
        Crobox.shared.configure(CroboxConfig(containerId: containerId, visitorId: CroboxVisitor.visitorId(), localeCode: LocaleCode("en_US")))
        
        /// Enable/Disable debugging
        Crobox.shared.isLoggingEnabled = true
        
        /// ViewContext contains view specific parameters, shared by all event and promotion requests sent from the same view.
        /// It must be re-created when the user visits a view, eg. the cart,
        let overviewView = ViewContext(viewId: UUID(), viewType: .overview, customProperties: ["test":"test"])
        
        //***************** EVENTS *********************
        
        /// Sending Click events with optional event specific parameters
        let clickParams = ClickParams(productId: "4", quantity: 3)
        Crobox.shared.clickEvent(view: overviewView, params: clickParams)
        
        /// Sending Add To Cart events with optional event specific parameters
        let addToCartParams = CartParams(productId: "3", quantity: 12)
        Crobox.shared.addToCartEvent(view: overviewView, params: addToCartParams)
        
        /// Sending Remove From Cart events with optional event specific parameters
        let removeFromCartParams = CartParams(productId: "3", quantity: 12)
        Crobox.shared.removeFromCartEvent(view: overviewView, params: removeFromCartParams)
        
        /// Sending Error events with optional event specific parameters
        let errorParams = ErrorParams(tag: "ParsingError", name: "IllegalArgumentException", message: "bad input")
        Crobox.shared.errorEvent(view: overviewView, params: errorParams)
        
        /// Sending general-purpose Custom event
        let customParams = CustomEventParams(name: "custom-event", promotionId: UUID(), productId: "3", quantity: 1)
        Crobox.shared.customEvent(view: overviewView, params: customParams)
        
        /// Sending view event
        let viewParams = ViewParams(
            title: "some page title",
            product: ProductParams(productId: "1", list: "related products"),
            searchTerms: "some search terms",
            impressions: [
                ProductParams(productId: "5"),
                ProductParams(productId: "8")
            ],
            customProperties: ["event-specific": "value1", "event-specific2": "value2"]
        )
        Crobox.shared.viewEvent(view: overviewView, params: viewParams)
        
        /// Sending checkout event
        let checkoutView = ViewContext(viewId: UUID(), viewType: .checkout, customProperties: ["checkout-specific":"yes"])
        
        let checkoutParams = CheckoutParams(
            products: [
                ProductParams(productId: "1"),
                ProductParams(productId: "2")
            ],
            step: "1",
            customProperties: ["page-specific-key":"value1"]
        )
        Crobox.shared.checkoutEvent(view: checkoutView, params: checkoutParams)
        
        /// Sending purchase event
        let completeView = ViewContext(viewId: UUID(), viewType: .complete, customProperties: ["complete-specific":"yes"])
        
        let purchaseParams = PurchaseParams(
            products: [
                ProductParams(productId: "1", quantity: 1),
                ProductParams(productId: "2", quantity: 2)
            ],
            transactionId: "trx-id-1",
            affiliation: "some online store",
            coupon: "discount 1",
            revenue: 5.0,
            customProperties: ["event-specific": "value and value2"]
        )
        Crobox.shared.purchaseEvent(view: completeView, params: purchaseParams)

        //*****************PROMOTIONS*********************
        Task {
            /// Requesting for a promotion from an overview view with a placementId configured for overview views in Crobox Container for a collection of products/impressions
            let result = await Crobox.shared.promotions(placementId: "1",
                                                        view: overviewView,
                                                        productIds: productIds)
            switch result {
            case let .success(response):
                self.printAll(response: response)
            case let .failure(error):
                print(error)
            }

            /// Requesting for a promotion from a product detail view with another placementId for a single product
            let detailView = ViewContext(viewId: UUID(), viewType: .detail)
            let resultPDP = await Crobox.shared.promotions(placementId: "1",
                                                           view: detailView,
                                                           productIds: ["1"])
            switch resultPDP {
            case let .success(response):
                self.printAll(response: response)
            case let .failure(error):
                print(error)
            }

            /// Requesting for a promotion from the checkout view with another placementId without any product
            let resultCheckout = await Crobox.shared.promotions(placementId: "2", view: checkoutView)
            switch resultCheckout {
            case let .success(response):
                self.printAll(response: response)
            case let .failure(error):
                print(error)
            }
        }
        
    }
    
    private func printAll(response: PromotionsResponse) {
        let context = response.context
        let p = context.visitorId
        print("VisitorId: \(p)")
        for c in context.campaigns {
            print("\tCampaign:[Id: \(c.id), Name: \(c.name)]")
        }
        print("Promotions: \(response.promotions.count)")
        for p in response.promotions {
            print("Id: \(p.id.uuidString)")
            print("Product: \(p.productId ?? "")")
            print("Campaign Id: \(p.campaignId)")
            print("Config: \(p.content?.config ?? [:])")
            
            
            switch p.content?.component() {
            case .imageBadge(let badge):
                print("Image: \(badge.imageUrl)")
                print("AltText: \(badge.altText ?? "")")
            case .textBadge(let badge):
                print("Text: \(badge.text)")
                print("Font color: \(badge.fontColor ?? UIColor.clear)")
                print("Border color: \(badge.borderColor ?? UIColor.clear)")
                print("Background: \(badge.backgroundLayer().map { "\($0)" } ?? "none")")
            case .secondaryMessaging(let messaging):
                print("Text: \(messaging.text)")
                print("Font color: \(messaging.fontColor ?? UIColor.clear)")
            case nil:
                print("n/a")
            }

        }
        
    }
}


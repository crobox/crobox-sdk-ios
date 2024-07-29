//
//  ViewController.swift
//  CroboxTestApp
//
//  Created by idris yıldız on 5.06.2024.
//

import UIKit
import croboxSDK

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let containerId = "xlrc9t"
        let productIds:Set<String> = ["1", "2", "3"]
        
        //Crobox.shared is the single point of contact for all interactions, keeping the configuration and providing all functionality
        Crobox.shared.initConfig(config: CroboxConfig(containerId: containerId, visitorId: UUID.init(), localeCode: .en_US))
        
        /// Enable/Disable debugging
        Crobox.shared.isDebug = true
        
        /// RequestQueryParams contains page specific parameters, shared by all event and promotion requests sent from the same page/view.
        /// Request params must be re-created when user visits a page/view, eg. CartPage,
        let overviewPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageOverview, customProperties: ["test":"test"])
        
        //***************** EVENTS *********************
        
        /// Sending Click events with optional event specific parameters
        let clickQueryParams = ClickQueryParams(productId: "4", price: 2.0, quantity: 3)
        Crobox.shared.clickEvent(queryParams: overviewPageParams, clickQueryParams: clickQueryParams)
        
        /// Sending Add To Cart events with optional event specific parameters
        let addCartQueryParams = CartQueryParams(productId: "3", price: 1.0, quantity: 12)
        Crobox.shared.addCartEvent(queryParams: overviewPageParams, addCartQueryParams:addCartQueryParams)
        
        /// Sending Remove From Cart events with optional event specific parameters
        let rmCartQueryParams = CartQueryParams(productId: "3", price: 1.0, quantity: 12)
        Crobox.shared.removeCartEvent(queryParams: overviewPageParams, rmCartQueryParams: rmCartQueryParams)
        
        /// Sending Error events with optional event specific parameters
        let errorParams = ErrorQueryParams(tag: "ParsingError", name: "IllegalArgumentException", message: "bad input")
        Crobox.shared.errorEvent(queryParams: overviewPageParams, errorQueryParams: errorParams)
        
        /// Sending general-purpose Custom event
        let customParams = CustomQueryParams(name: "custom-event", promotionId: UUID(), productId: "3", price: 1.0, quantity: 1)
        Crobox.shared.customEvent(queryParams: overviewPageParams, customQueryParams: customParams)
        
        /// Sending page view event
        let pageViewParams = PageViewParams(
            pageTitle: "some page title",
            product: ProductParams(productId: "1", price: 1.0, otherProductIds: ["2", "3", "4"]),
            searchTerms: "some search terms",
            impressions: [
                ProductParams(productId: "5"),
                ProductParams(productId: "8")
            ],
            customProperties: ["event-specific": "value1", "event-specific2": "value2"]
        )
        Crobox.shared.pageViewEvent(queryParams: overviewPageParams, pageViewParams: pageViewParams)
        
        /// Sending checkout event
        let checkoutPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageCheckout, customProperties: ["checkout-specific":"yes"])
        
        let checkoutParams = CheckoutParams(
            products: [
                ProductParams(productId: "1"),
                ProductParams(productId: "2")
            ],
            step: "step-1",
            customProperties: ["page-specific-key":"value1"]
        )
        Crobox.shared.checkoutEvent(queryParams: checkoutPageParams, checkoutParams: checkoutParams)
        
        /// Sending purchase event
        let pageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageComplete, customProperties: ["complete-specific":"yes"])
        
        let purchaseParams = PurchaseParams(
            products: [
                ProductParams(productId: "1", price: 1.0, quantity:  1, otherProductIds: ["1", "3", "5"]),
                ProductParams(productId: "2", price: 2.0, quantity : 2, otherProductIds: ["2", "4", "6"])
            ],
            transactionId: "trx-id-1",
            affiliation: "some online store",
            coupon: "discount 1",
            revenue: 5.0,
            customProperties: ["event-specific": "value and value2"]
        )
        Crobox.shared.purchaseEvent(queryParams: pageParams, purchaseParams: purchaseParams)

        //*****************PROMOTIONS*********************
        Task {
            /// Requesting for a promotion from an overview Page with placeholderId configured for Overview Pages in Crobox Container for a collection of products/impressions
            let result = await Crobox.shared.promotions(placeholderId: "1",
                                                        queryParams: overviewPageParams,
                                                        productIds: productIds)
            switch result {
            case let .success(response):
                self.printAll(response: response)
            case let .failure(error):
                print(error)
            }

            /// Requesting for a promotion from a product detail page with another placeholderId for a single product
            let detailPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageDetail)
            let resultPDP = await Crobox.shared.promotions(placeholderId: "1",
                                                           queryParams: detailPageParams,
                                                           productIds: ["1"])
            switch resultPDP {
            case let .success(response):
                self.printAll(response: response)
            case let .failure(error):
                print(error)
            }

            /// Requesting for a promotion from Checkout Page with another placeholderId without any product
            let resultCheckout = await Crobox.shared.promotions(placeholderId: "2", queryParams: checkoutPageParams)
            switch resultCheckout {
            case let .success(response):
                self.printAll(response: response)
            case let .failure(error):
                print(error)
            }
        }
        
    }
    
    private func printAll(response: PromotionResponse) {
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
            
            
            let badge = p.content?.contentConfig()
            switch badge {
            case let badge as ImageBadge:
                print("Image: \(badge.image)")
                print("AltText: \(badge.altText ?? "")")
            case let badge as TextBadge:
                print("Text: \(badge.text)")
                print("FontColor: \(badge.fontColor ?? "")")
                print("Background: \(badge.backgroundColor ?? "")")
                print("BorderColor: \(badge.borderColor ?? "")")
                
                print("Font UIColor: \(badge.fontUIColor() ?? UIColor.clear )")
                print("Background UIColor: \(badge.backgroundUIColor() ?? UIColor.clear)")
                print("Border UIColor: \(badge.borderUIColor() ?? UIColor.clear)")
                
            case let badge as SecondaryMessaging:
                print("Text: \(badge.text)")
                print("FontColor: \(badge.fontColor ?? "")")
                print("FontUIColor: \(badge.fontUIColor() ?? UIColor.clear)")
            default:
                print("n/a")
            }

        }
        
    }
}


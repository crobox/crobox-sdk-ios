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
        
        /// Crobox.shared is the single point of all interactions, keeping the configuration and providing all functionality
        Crobox.shared.initConfig(config: CroboxConfig(containerId: "xlhvci", visitorId: UUID.init(), localeCode: .en_US))
        
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
        Crobox.shared.addCartEvent(queryParams: overviewPageParams, addCartQueryParams:addCartQueryParams )
        
        /// Sending Remove From Cart events with optional event specific parameters
        let rmCartQueryParams = CartQueryParams(productId: "3", price: 1.0, quantity: 12)
        Crobox.shared.removeCartEvent(queryParams: overviewPageParams, rmCartQueryParams: rmCartQueryParams)
        
        /// Sending Error events with optional event specific parameters
        let errorParams = ErrorQueryParams(tag: "ParsingError", name: "IllegalArgumentException", message: "bad input")
        Crobox.shared.errorEvent(queryParams: overviewPageParams, errorQueryParams: errorParams)
        
        /// Sending general-purpose Custom event
        let customParams = CustomQueryParams(name: "custom-event", promotionId: UUID(), productId: "3", price: 1.0, quantity: 1)
        Crobox.shared.customEvent(queryParams: overviewPageParams, customQueryParams: customParams)
        
        //*****************PROMOTIONS*********************
        
        /// Requesting for a promotion from an overview Page with placeholderId configured for Overview Pages in Crobox Container for a collection of products/impressions
        Crobox.shared.promotions(placeholderId: "1",
                                 queryParams: overviewPageParams,
                                 productIds: ["1", "2", "3"]) { isSuccess, promotionResponse in
            /// process PromotionResponse
            ///
            if let items = promotionResponse?.promotions
            {
                for item in items
                {
                    print(item.content?.config?.data ?? "no data")
                    print(item.campaignId!)
                    print(item.id!)
                    print(item.productId! )
                }
            }
        }
                
        /// Requesting for a promotion from a product detail page with another placeholderId for a single product
        let detailPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageDetail)
        Crobox.shared.promotions(placeholderId: "1",
                                 queryParams: detailPageParams,
                                 productIds: ["1"]) { isSuccess, promotionResponse in
            /// process PromotionResponse

        }

        /// Requesting for a promotion from Checkout Page with another placeholderId without any product
        let checkoutPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageCheckout)
        Crobox.shared.promotions(placeholderId: "2", queryParams: checkoutPageParams) { isSuccess, promotionResponse in
            /// process PromotionResponse
        }
        
        
    }
}


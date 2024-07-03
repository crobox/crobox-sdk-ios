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
        
        Crobox.shared.isDebug = true
        
        
        Crobox.shared.initConfig(config: CroboxConfig(containerId: "xlhvci", visitorId: UUID.init(), localeCode: .en_US))
        
        let params = RequestQueryParams.init(viewId: UUID(), pageType: .PageCart, customProperties: ["test":"test"])
        
        //................
        
        //example pageview with AddCart Event and with additionalParams as AddCartQueryParams
        var addCartQueryParams = CartQueryParams(productId: "", price: 1.0, quantity: 12)// All Optional
        
        Crobox.shared.addCartEvent(queryParams: params, addCartQueryParams:addCartQueryParams )
        
        
        //example pageview with Click Event and with additionalParams as additionalClickParams
        var clickQueryParams = ClickQueryParams() // All Optional
        clickQueryParams.productId = "4"
        clickQueryParams.price = 2.0
        clickQueryParams.quantity = 3
        
        Crobox.shared.clickEvent(queryParams: params, clickQueryParams: clickQueryParams)
        
        
        //example pageview with Click Event and without additionalParams
        Crobox.shared.clickEvent(queryParams: params)
        
        
        //*****************PROMOTIONS*********************
        
        //get promotions without additionalParams
        Crobox.shared.promotions(placeholderId: "14",
                                 queryParams: params) { isSuccess, promotionResponse in
            
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
    }
}


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
        
        Crobox.shared.isDebug = true
        
        
        Crobox.shared.initConfig(config: CroboxConfig(containerId: "xlhvci", visitorId: UUID.init(), localeCode: .en_US))
        
        let params = RequestQueryParams.init(viewId: UUID(), pageType : .PageDetail, customProperties = ["test":"test"])
        
        //................
        
        //example pageview with AddCart Event and with additionalParams as AddCartQueryParams
        var addCartQueryParams = CartQueryParams(productId: "abc123", price = 2.0, quantity = 3  )// All Optional
        
        Crobox.shared.addCartEvent(queryParams: params,
                                      addCartQueryParams:addCartQueryParams ) { isSuccess, jsonObject in
            
        }
        
        
        //example pageview with Click Event and with additionalParams as additionalClickParams
        var clickQueryParams = ClickQueryParams() // All Optional
        clickQueryParams.productId = "4"
        clickQueryParams.category = "1"
        clickQueryParams.price = 2.0
        clickQueryParams.quantity = 3
        
        Crobox.shared.clickEvent(queryParams: params,
                                    clickQueryParams: clickQueryParams) { isSuccess, jsonObject in
            
        }
        
        
        //example pageview with Click Event and without additionalParams
        Crobox.shared.clickEvent(queryParams: params) { isSuccess, jsonObject in
            
        }
        
        
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


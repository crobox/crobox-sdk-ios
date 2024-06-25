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
        
        Crobox.shared.setContainerId(containerId: "xlhvci")// Mandatory
        
        var params = RequestQueryParams(viewCounter: 28, viewId: "An0N-dq0ThWeiUJX12cpVA", visitorId: "H9O1I0kYSaekKFrzS_JWCg")
        params.pageType = .PageDetail
        params.localeCode = .en_US
        //................
        
        //example pageview with AddCart Event and with additionalParams as AddCartQueryParams
        var addCartQueryParams = AddCartQueryParams(productId: "")// All Optional
        addCartQueryParams.category = "1"
        addCartQueryParams.price = 2.0
        addCartQueryParams.quantity = 3
        
        Crobox.shared.pageViewAddCart(queryParams: params,
                                      addCartQueryParams:addCartQueryParams ) { isSuccess, jsonObject in
            
        }
        
        
        //example pageview with Click Event and with additionalParams as additionalClickParams
        var clickQueryParams = ClickQueryParams() // All Optional
        clickQueryParams.productId = "4"
        clickQueryParams.category = "1"
        clickQueryParams.price = 2.0
        clickQueryParams.quantity = 3
        
        Crobox.shared.pageViewClick(queryParams: params,
                                    clickQueryParams: clickQueryParams) { isSuccess, jsonObject in
            
        }
        
        
        //example pageview with Click Event and without additionalParams
        Crobox.shared.pageViewClick(queryParams: params) { isSuccess, jsonObject in
            
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


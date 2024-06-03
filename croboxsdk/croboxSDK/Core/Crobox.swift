//
//  Crobox.swift
//  croboxsdk
//
//  Created by idris yıldız on 22.05.2024.
//

import Foundation
import Alamofire
import SwiftyJSON

class Crobox {
    
    /*
     croboxSDK instance
     */
    public static let shared = Crobox()
   
    /*
     enable or disable debug
     */
    var isDebug = false
    
    func pageView(eventType:EventType!, queryParams: RequestQueryParams,
                  additionalParams:Any?,
                  closure: @escaping (_ isSuccess:Bool, _ promotionResponse: PromotionResponse?) -> Void){
        
        CroboxAPIServices.shared.socket(eventType: eventType, additionalParams: additionalParams, queryParams: queryParams) { isSuccess, promotionResponse in
            closure(isSuccess, promotionResponse)
        }
        
    }
    
    func testfunc()
    {
        var queryParams = RequestQueryParams()
        queryParams.localeCode = .af_ZA
        //.....


        //example event additionalParams
        let clickParams = ClickQueryParams(
            productId: "123",
            category: "books",
            price: 12.99,
            quantity: 1
        )
        
        pageView(eventType: .CustomEvent, queryParams: queryParams, additionalParams: clickParams ) { isSuccess, promotionResponse in
            print(promotionResponse!)
      
        }
    }
   
}

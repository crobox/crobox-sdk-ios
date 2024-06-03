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
    
    func pageView(eventType:EventType!, queryParams: RequestQueryParams, closure: @escaping (_ isSuccess:Bool, _ promotionResponse: PromotionResponse?) -> Void){
        CroboxAPIServices.shared.socket(eventType: eventType, queryParams: queryParams) { isSuccess, promotionResponse in
            closure(isSuccess, promotionResponse)
        }
    }
    
    func testfunc()
    {
        var queryParams = RequestQueryParams()
        queryParams.localeCode = .af_ZA
        queryParams.errorQueryParams?.name = ""
        
        pageView(eventType: .CustomEvent, queryParams: queryParams) { isSuccess, promotionResponse in
            print(promotionResponse!)
        }
    }
   
}

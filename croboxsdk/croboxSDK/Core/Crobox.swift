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
    
    public static let shared = Crobox()
    /*
     enable or disable debug
     */
    var isDebug = false
    
    func pageView(queryParams: RequestQueryParams, closure: @escaping (_ isSuccess:Bool, _ promotionResponse: PromotionResponse?) -> Void){
        CroboxAPIServices.shared.socket(queryParams: queryParams) { isSuccess, promotionResponse in
            closure(isSuccess, promotionResponse)
        }
    }
    
    func testfunc()
    {
        var qq = RequestQueryParams()
        
        qq.localeCode = .af_ZA
        
        pageView(queryParams: qq) { isSuccess, promotionResponse in
             
            print(promotionResponse)
        }
    }
   
}

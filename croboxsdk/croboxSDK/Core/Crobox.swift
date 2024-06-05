//
//  Crobox.swift
//  croboxsdk
//
//  Created by idris yıldız on 22.05.2024.
//

import Foundation
import Alamofire
import SwiftyJSON

public class Crobox {
    
    /*
     croboxSDK instance
     */
    public static let shared = Crobox()
    
    /*
     enable or disable debug
     */
    public var isDebug = false
    
    public func pageView(eventType:EventType!, queryParams: RequestQueryParams,
                  additionalParams:Any?,
                  closure: @escaping (_ isSuccess:Bool, _ promotionResponse: PromotionResponse?) -> Void){
        
        CroboxAPIServices.shared.socket(eventType: eventType, additionalParams: additionalParams, queryParams: queryParams) { isSuccess, promotionResponse in
            closure(isSuccess, promotionResponse)
        }
    }
}

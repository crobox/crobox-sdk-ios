//
//  CroboxAPIServices.swift
//  croboxsdk
//
//  Created by idris yıldız on 23.05.2024.
//

import Foundation

class CroboxAPIServices {
    
    static let shared = CroboxAPIServices()
    
    func promotions(queryParams:RequestQueryParams, closure: @escaping (_ isSuccess:Bool, _ promotionResponse: PromotionResponse?) -> Void) {
        
        //Mandatory
        var parameters = [
            "cid": queryParams.containerId!,
            "e": queryParams.viewCounter!,
            "vid": queryParams.viewId!,
            "pid": queryParams.visitorId!,
        ] as [String : Any]
        
        //Optional
        if let currencyCode = queryParams.currencyCode {
            parameters["cc"] = currencyCode
        }
        if let localeCode = queryParams.localeCode {
            parameters["lc"] = localeCode
        }
        if let userId = queryParams.userId {
            parameters["uid"] = userId
        }
        if let timestamp = queryParams.timestamp {
            parameters["ts"] = timestamp
        }
        if let timezone = queryParams.timezone {
            parameters["tz"] = timezone
        }
        if let pageType = queryParams.pageType {
            parameters["pt"] = pageType
        }
        if let customProperties = queryParams.customProperties {
            parameters["cp"] = customProperties
        }
        if let customProperties = queryParams.customProperties {
            parameters["lh"] = customProperties
        }
        if let customProperties = queryParams.referrerUrl {
            parameters["rf"] = customProperties
        }
        
        APIRequests.shared.request(method: .post, url: Constant.Promotions_Path , parameters: parameters ) {
            (jsonObject, success) in
            
            var promotionResponse:PromotionResponse?
            
            if success {
                
                if jsonObject == nil && !(jsonObject?.isEmpty ?? false) {
                    
                    promotionResponse = PromotionResponse(jsonData: jsonObject!)
                    
                    closure(true, promotionResponse)
                    
                } else {
                    
                    closure(false, promotionResponse)
                }
                
            } else {
                
                closure(false, promotionResponse)
            }
        }
    }
    
    func socket(queryParams:RequestQueryParams,closure: @escaping (_ isSuccess:Bool, _ promotionResponse: PromotionResponse?) -> Void) {
        
        //Mandatory
        var parameters = [
            "cid": queryParams.containerId!,
            "e": queryParams.viewCounter!,
            "vid": queryParams.viewId!,
            "pid": queryParams.visitorId!,
        ] as [String : Any]
        
        //Optional
        if let currencyCode = queryParams.currencyCode {
            parameters["cc"] = currencyCode
        }
        if let localeCode = queryParams.localeCode {
            parameters["lc"] = localeCode
        }
        if let userId = queryParams.userId {
            parameters["uid"] = userId
        }
        if let timestamp = queryParams.timestamp {
            parameters["ts"] = timestamp
        }
        if let timezone = queryParams.timezone {
            parameters["tz"] = timezone
        }
        if let pageType = queryParams.pageType {
            parameters["pt"] = pageType
        }
        if let customProperties = queryParams.pageUrl {
            parameters["cp"] = customProperties
        }
        if let customProperties = queryParams.customProperties {
            parameters["lh"] = customProperties
        }
        if let customProperties = queryParams.referrerUrl {
            parameters["rf"] = customProperties
        }
        
        APIRequests.shared.request(method: .post, url: Constant.Socket_Path , parameters: parameters ) {
            (jsonObject, success) in
            
            var promotionResponse:PromotionResponse?
            
            if success {
                
                if jsonObject == nil && !(jsonObject?.isEmpty ?? false) {
                    
                    promotionResponse = PromotionResponse(jsonData: jsonObject!)
                    
                    closure(true, promotionResponse)
                    
                } else {
                    
                    closure(false, promotionResponse)
                }
                
            } else {
                
                closure(false, promotionResponse)
            }
        }
    }
}


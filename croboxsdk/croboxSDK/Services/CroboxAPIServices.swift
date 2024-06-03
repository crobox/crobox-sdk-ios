//
//  CroboxAPIServices.swift
//  croboxsdk
//
//  Created by idris yıldız on 23.05.2024.
//

import Foundation

class CroboxAPIServices {
    
    static let shared = CroboxAPIServices()
    
    func promotions(queryParams:RequestQueryParams,
                    closure: @escaping (_ isSuccess:Bool, _ promotionResponse: PromotionResponse?) -> Void) {
        
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
    
    func socket(eventType:EventType!, queryParams:RequestQueryParams,closure: @escaping (_ isSuccess:Bool, _ promotionResponse: PromotionResponse?) -> Void) {
        
        //Mandatory
        var parameters = [
            "cid": queryParams.containerId!,
            "e": queryParams.viewCounter!,
            "vid": queryParams.viewId!,
            "pid": queryParams.visitorId!,
            "t": eventType.rawValue
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
        
        checkEventType(eventType:eventType, queryParams:queryParams, parameters: &parameters)
        
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



// check for event type
extension CroboxAPIServices
{
    func checkEventType(eventType:EventType!, queryParams:RequestQueryParams, parameters: inout [String : Any])
    {
        switch eventType {
        case .Click:
            clickEvent(queryParams: queryParams, parameters: &parameters)
            break
        case .AddCart:
            //TODO
            break
        case .RemoveCart:
            //TODO
            break
        case .Transaction:
            //TODO
            break
        case .PageView:
            //TODO
            break
        case .Error:
            errorEvent(queryParams: queryParams, parameters: &parameters)
            break
        case .CustomEvent:
            //TODO
            break
        case .Product:
            //TODO
            break
        case .ProductFinder:
            //TODO
            break
        default:
            print("none")
        }
    }
    
}


/*
 
 The following arguments are applicable for error events( where t=error ). They are all optional.
 
 */

extension CroboxAPIServices
{
    func errorEvent(queryParams:RequestQueryParams, parameters: inout [String : Any])
    {
        if let tag = queryParams.errorQueryParams?.tag {
            parameters["tg"] = tag
        }
        if let name = queryParams.errorQueryParams?.name {
            parameters["nm"] = name
        }
        if let message = queryParams.errorQueryParams?.message {
            parameters["msg"] = message
        }
        if let file = queryParams.errorQueryParams?.file {
            parameters["f"] = file
        }
        if let line = queryParams.errorQueryParams?.line {
            parameters["l"] = line
        }
        if let devicePixelRatio = queryParams.errorQueryParams?.devicePixelRatio {
            parameters["dpr"] = devicePixelRatio
        }
        if let deviceLanguage = queryParams.errorQueryParams?.deviceLanguage {
            parameters["ul"] = deviceLanguage
        }
        if let viewPortSize = queryParams.errorQueryParams?.viewPortSize {
            parameters["vp"] = viewPortSize
        }
        if let screenResolutionSize = queryParams.errorQueryParams?.screenResolutionSize {
            parameters["sr"] = screenResolutionSize
        }
    }
}


/*
 
 The following arguments are applicable for click events( where t=click ). They are all optional

 */

extension CroboxAPIServices
{
    func clickEvent(queryParams:RequestQueryParams, parameters: inout [String : Any])
    {
        if let productId = queryParams.clickQueryParams?.productId {
            parameters["pi"] = productId
        }
        if let category = queryParams.clickQueryParams?.category {
            parameters["cat"] = category
        }
        if let price = queryParams.clickQueryParams?.price {
            parameters["price"] = price
        }
        if let quantity = queryParams.clickQueryParams?.quantity {
            parameters["qty"] = quantity
        }
    }
}

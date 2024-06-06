//
//  CroboxAPIServices.swift
//  croboxsdk
//
//  Created by idris yıldız on 23.05.2024.
//

import Foundation
import SwiftyJSON
import Alamofire

class CroboxAPIServices {
    
    static let shared = CroboxAPIServices()
    
    func promotions(queryParams:RequestQueryParams,
                    closure: @escaping (_ isSuccess:Bool, _ promotionResponse: PromotionResponse?) -> Void) {
        
        //Mandatory
        var parameters = [
            "cid": queryParams.containerId,
            "e": queryParams.viewCounter,
            "vid": queryParams.viewId,
            "pid": queryParams.visitorId,
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
    
    func socket(eventType:EventType!, additionalParams:Any?, queryParams:RequestQueryParams, closure: @escaping (_ isSuccess:Bool, _ promotionResponse: PromotionResponse?) -> Void) {
        
        //Mandatory
        var parameters = [
            "cid": queryParams.containerId,
            "e": queryParams.viewCounter,
            "vid": queryParams.viewId,
            "pid": queryParams.visitorId,
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
        
        checkEventType(eventType:eventType,
                       additionalParams: additionalParams,
                       parameters: &parameters)
        
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
    func checkEventType(eventType:EventType!, additionalParams: Any?, parameters: inout [String : Any])
    {
        switch eventType {
        case .Click:
            if let clickParams = additionalParams as? ClickQueryParams {
                clickEvent(clickParams: clickParams, parameters: &parameters)
            }
            break
        case .AddCart:
            if let addCartQueryParams = additionalParams as? AddCartQueryParams {
                addToCartEvent(addCartQueryParams: addCartQueryParams, parameters: &parameters)
            }
            break
        case .RemoveCart:
            if let removeFromCartQueryParams = additionalParams as? RemoveFromCartQueryParams {
                removeFromCartEvent(removeFromCartQueryParams: removeFromCartQueryParams, parameters: &parameters)
            }
            break
        case .PageView:
            //TODO
            break
        case .Error:
            if let errorQueryParams = additionalParams as? ErrorQueryParams {
                errorEvent(errorQueryParams: errorQueryParams, parameters: &parameters)
            }
            break
        case .CustomEvent:
            if let customQueryParams = additionalParams as? CustomQueryParams {
                customEvent(customQueryParams: customQueryParams, parameters: &parameters)
            }
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
    func errorEvent(errorQueryParams:ErrorQueryParams, parameters: inout [String : Any])
    {
        if let tag = errorQueryParams.tag {
            parameters["tg"] = tag
        }
        if let name = errorQueryParams.name {
            parameters["nm"] = name
        }
        if let message = errorQueryParams.message {
            parameters["msg"] = message
        }
        if let file = errorQueryParams.file {
            parameters["f"] = file
        }
        if let line = errorQueryParams.line {
            parameters["l"] = line
        }
        if let devicePixelRatio = errorQueryParams.devicePixelRatio {
            parameters["dpr"] = devicePixelRatio
        }
        if let deviceLanguage = errorQueryParams.deviceLanguage {
            parameters["ul"] = deviceLanguage
        }
        if let viewPortSize = errorQueryParams.viewPortSize {
            parameters["vp"] = viewPortSize
        }
        if let screenResolutionSize = errorQueryParams.screenResolutionSize {
            parameters["sr"] = screenResolutionSize
        }
    }
}


/*
 
 The following arguments are applicable for click events( where t=click ). They are all optional
 
 */

extension CroboxAPIServices
{
    func clickEvent(clickParams:ClickQueryParams, parameters: inout [String : Any])
    {
        if let productId = clickParams.productId {
            parameters["pi"] = productId
        }
        if let category = clickParams.category {
            parameters["cat"] = category
        }
        if let price = clickParams.price {
            parameters["price"] = price
        }
        if let quantity = clickParams.quantity {
            parameters["qty"] = quantity
        }
    }
}


/*
 
 The following arguments are applicable for AddToCart events( where t=cart ). They are all optional
 
 */

extension CroboxAPIServices
{
    func addToCartEvent(addCartQueryParams:AddCartQueryParams, parameters: inout [String : Any])
    {
        if let productId = addCartQueryParams.productId {
            parameters["pi"] = productId
        }
        if let category = addCartQueryParams.category {
            parameters["cat"] = category
        }
        if let price = addCartQueryParams.price {
            parameters["price"] = price
        }
        if let quantity = addCartQueryParams.quantity {
            parameters["qty"] = quantity
        }
    }
}


/*
 
 The following arguments are applicable for RemoveFromCart events( where t=rmcart ). They are all optional
 
 */

extension CroboxAPIServices
{
    func removeFromCartEvent(removeFromCartQueryParams:RemoveFromCartQueryParams, parameters: inout [String : Any])
    {
        if let productId = removeFromCartQueryParams.productId {
            parameters["pi"] = productId
        }
        if let category = removeFromCartQueryParams.category {
            parameters["cat"] = category
        }
        if let price = removeFromCartQueryParams.price {
            parameters["price"] = price
        }
        if let quantity = removeFromCartQueryParams.quantity {
            parameters["qty"] = quantity
        }
    }
}


/*
 
 The following arguments are applicable for click events( where t=event ). They are all optional

 */

extension CroboxAPIServices
{
    func customEvent(customQueryParams:CustomQueryParams, parameters: inout [String : Any])
    {
        if let name = customQueryParams.name {
            parameters["nm"] = name
        }
        if let promotionID = customQueryParams.promotionId {
            parameters["promoId"] = promotionID
        }
        if let productID = customQueryParams.productId {
            parameters["pi"] = productID
        }
        if let price = customQueryParams.price {
            parameters["price"] = price
        }
        if let quantity = customQueryParams.quantity {
            parameters["qty"] = quantity
        }
    }
}




//
//  CroboxAPIServices.swift
//  croboxsdk
//
//  Created by idris yıldız on 23.05.2024.
//

import Foundation

class CroboxAPIServices {
    
    static let shared = CroboxAPIServices()
    
    func promotions(parameters:[String: Any], closure: @escaping (_ isSuccess:Bool, _ promotionResponse: PromotionResponse?) -> Void) {
      
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
    
    func socket(parameters:[String: Any], closure: @escaping (_ isSuccess:Bool, _ promotionResponse: PromotionResponse?) -> Void) {
      
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



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
    
    /*
     have to setted when init SDK on app, it is
     */
    public var config:CroboxConfig!
    
    
    public func initConfig(config:CroboxConfig) {
        self.config =  config
    }
    
    public func clickEvent(queryParams: RequestQueryParams!,
                              clickQueryParams:ClickQueryParams? = nil,
                              closure: @escaping (_ isSuccess:Bool, _ jsonObject: JSON?) -> Void){
        
        CroboxAPIServices.shared.socket(eventType: .Click, additionalParams: clickQueryParams, queryParams: queryParams) { isSuccess, jsonObject in
            closure(isSuccess, jsonObject)
        }
    }
    
    public func addCartEvent(queryParams: RequestQueryParams!,
                                addCartQueryParams:CartQueryParams? = nil,
                              closure: @escaping (_ isSuccess:Bool, _ jsonObject: JSON?) -> Void){
        
        CroboxAPIServices.shared.socket(eventType: .AddCart, additionalParams: addCartQueryParams, queryParams: queryParams) { isSuccess, jsonObject in
            closure(isSuccess, jsonObject)
        }
    }
    
    public func removeCartEvent(queryParams: RequestQueryParams!,
                                   removeFromCartQueryParams:CartQueryParams? = nil,
                              closure: @escaping (_ isSuccess:Bool, _ jsonObject: JSON?) -> Void){
        
        CroboxAPIServices.shared.socket(eventType: .RemoveCart, additionalParams: removeFromCartQueryParams, queryParams: queryParams) { isSuccess, jsonObject in
            closure(isSuccess, jsonObject)
        }
    }
    
    
    public func errorEvent(queryParams: RequestQueryParams!,
                              errorQueryParams:ErrorQueryParams? = nil,
                              closure: @escaping (_ isSuccess:Bool, _ jsonObject: JSON?) -> Void){
        
        CroboxAPIServices.shared.socket(eventType: .Error, additionalParams: errorQueryParams, queryParams: queryParams) { isSuccess, jsonObject in
            closure(isSuccess, jsonObject)
        }
    }
    
    public func pageViewEvent(queryParams: RequestQueryParams!,
                              customQueryParams:CustomQueryParams? = nil,
                              closure: @escaping (_ isSuccess:Bool, _ jsonObject: JSON?) -> Void){
        
        CroboxAPIServices.shared.socket(eventType: .CustomEvent, additionalParams: customQueryParams, queryParams: queryParams) { isSuccess, jsonObject in
            closure(isSuccess, jsonObject)
        }
    }
    
    public func promotions(placeholderId:String!,
                           queryParams: RequestQueryParams!,
                           closure: @escaping (_ isSuccess:Bool, _ promotionResponse: PromotionResponse?) -> Void){
        
        CroboxAPIServices.shared.promotions(placeholderId: placeholderId, queryParams: queryParams) { isSuccess, promotionResponse in
            closure(isSuccess, promotionResponse)
        }
    }
}

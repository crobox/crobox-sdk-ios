
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


    /// For sending a Click Event, to track the ratio of visits on impressions.
    ///
    /// Click events forms the measurement data for Click-through rate (CTR) for campaigns.
    ///
    /// - Parameter queryParams: Common query parameters, shared by the requests sent from the same page view
    /// - Parameter clickQueryParams: Event specific query parameters for Click Events
    /// - Parameter eventCallback: The callback to be notified for the response or if an error occurs before, during or after the request is sent
    public func clickEvent(queryParams: RequestQueryParams!,
                              clickQueryParams:ClickQueryParams? = nil,
                              closure: @escaping (_ isSuccess:Bool, _ jsonObject: JSON?) -> Void){
        
        CroboxAPIServices.shared.socket(eventType: .Click, additionalParams: clickQueryParams, queryParams: queryParams) { isSuccess, jsonObject in
            closure(isSuccess, jsonObject)
        }
    }

    /// For sending an Add To Cart Event, to track the metrics of customer's intention of making a purchase.
    ///
    /// - Parameter queryParams: Common query parameters, shared by the requests sent from the same page view
    /// - Parameter cartQueryParams: Event specific query parameters for AddToCart and RemoveFromCart Events
    /// - Parameter eventCallback: The callback to be notified for the response or if an error occurs before, during or after the request is sent
    public func addCartEvent(queryParams: RequestQueryParams!,
                                addCartQueryParams:CartQueryParams? = nil,
                              closure: @escaping (_ isSuccess:Bool, _ jsonObject: JSON?) -> Void){
        
        CroboxAPIServices.shared.socket(eventType: .AddCart, additionalParams: addCartQueryParams, queryParams: queryParams) { isSuccess, jsonObject in
            closure(isSuccess, jsonObject)
        }
    }

    /// For sending an Remove From Cart Event, to track the metrics of product's removal from a purchase.
    ///
    /// - Parameter queryParams: Common query parameters, shared by the requests sent from the same page view
    /// - Parameter cartQueryParams: Event specific query parameters for AddToCart and RemoveFromCart Events
    /// - Parameter eventCallback: The callback to be notified for the response or if an error occurs before, during or after the request is sent
    public func removeCartEvent(queryParams: RequestQueryParams!,
                                   removeFromCartQueryParams:CartQueryParams? = nil,
                              closure: @escaping (_ isSuccess:Bool, _ jsonObject: JSON?) -> Void){
        
        CroboxAPIServices.shared.socket(eventType: .RemoveCart, additionalParams: removeFromCartQueryParams, queryParams: queryParams) { isSuccess, jsonObject in
            closure(isSuccess, jsonObject)
        }
    }
    
    /// For reporting a general-purpose error event
    ///
    /// - Parameter queryParams: Common query parameters, shared by the requests sent from the same page view
    /// - Parameter errorQueryParams: Event specific query parameters for Error Events
    /// - Parameter eventCallback: The callback to be notified for the response or if an error occurs before, during or after the request is sent
    public func errorEvent(queryParams: RequestQueryParams!,
                              errorQueryParams:ErrorQueryParams? = nil,
                              closure: @escaping (_ isSuccess:Bool, _ jsonObject: JSON?) -> Void){
        
        CroboxAPIServices.shared.socket(eventType: .Error, additionalParams: errorQueryParams, queryParams: queryParams) { isSuccess, jsonObject in
            closure(isSuccess, jsonObject)
        }
    }
    /// For reporting custom events
    ///
    /// - Parameter queryParams: Common query parameters, shared by the requests sent from the same page view
    /// - Parameter customQueryParams: Event specific query parameters for Custom Events
    /// - Parameter eventCallback: The callback to be notified for the response or if an error occurs before, during or after the request is sent
    public func customEvent(queryParams: RequestQueryParams!,
                              customQueryParams:CustomQueryParams? = nil,
                              closure: @escaping (_ isSuccess:Bool, _ jsonObject: JSON?) -> Void){
        
        CroboxAPIServices.shared.socket(eventType: .CustomEvent, additionalParams: customQueryParams, queryParams: queryParams) { isSuccess, jsonObject in
            closure(isSuccess, jsonObject)
        }
    }
    /// For retrieval of Promotions
    ///
    ///  A Placeholder represent a predesignated point on the user interface, where the promotion will be located and displayed.
    ///  Placeholders are linked with Campaigns which has all promotion attributes, UI components, messages, time frame etc.
    ///  These are all managed via the Crobox Admin application.
    ///
    /// - Parameter placeholderId: Identifier of the placeholder
    /// - Parameter queryParams: Common query parameters, shared by the requests sent from the same page view
    /// - Parameter impressions: List of product ID's which promotions are requested for. It may be empty for the pages where products are not involved. (e.g. Checkout page)
    /// - Parameter promotionCallback: The callback to be notified for the response or if an error occurs before, during or after the request is sent
    public func promotions(placeholderId:String!,
                           queryParams: RequestQueryParams!,
                           closure: @escaping (_ isSuccess:Bool, _ promotionResponse: PromotionResponse?) -> Void){
        
        CroboxAPIServices.shared.promotions(placeholderId: placeholderId, queryParams: queryParams) { isSuccess, promotionResponse in
            closure(isSuccess, promotionResponse)
        }
    }
}

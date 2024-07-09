
import Foundation
import Alamofire
import SwiftyJSON

public class Crobox {
    
    /*
     CroboxSDK instance
     */
    public static let shared = Crobox()
    
    /*
     enable or disable debug. Prints errors if enabled
     */
    public var isDebug = false
    
    /*
     mandatory for common configuration parameters
     */
    public var config:CroboxConfig!
    
    
    public func initConfig(config:CroboxConfig) {
        self.config =  config
    }
    
    /// For sending a Click Event, to track the ratio of visits on impressions.
    ///
    /// - Note: Click events forms the measurement data for Click-through rate (CTR) for campaigns.
    ///
    /// - Parameter queryParams: Common query parameters, shared by the requests sent from the same page view
    /// - Parameter clickQueryParams: Event specific query parameters for Click Events
    public func clickEvent(queryParams: RequestQueryParams!, clickQueryParams:ClickQueryParams? = nil) async {
        CroboxAPIServices.shared.socket(eventType: .Click, additionalParams: clickQueryParams, queryParams: queryParams){result in
            switch result {
            case .success(_):
                ()
            case let .failure(error):
                if self.isDebug {
                    print(error)
                }
        }
    }
    
    /// For sending an Add To Cart Event, to track the metrics of customer's intention of making a purchase.
    ///
    /// - Parameter queryParams: Common query parameters, shared by the requests sent from the same page view
    /// - Parameter addCartQueryParams: Event specific query parameters for AddToCart and RemoveFromCart Events
    public func addCartEvent(queryParams: RequestQueryParams!, addCartQueryParams:CartQueryParams? = nil) async {
        CroboxAPIServices.shared.socket(eventType: .AddCart, additionalParams: addCartQueryParams, queryParams: queryParams) {result in
            switch result {
            case .success(_):
                ()
            case let .failure(error):
                print(error)
            }
        }
    }
    
    /// For sending an Remove From Cart Event, to track the metrics of product's removal from a purchase.
    ///
    /// - Parameter queryParams: Common query parameters, shared by the requests sent from the same page view
    /// - Parameter rmCartQueryParams: Event specific query parameters for AddToCart and RemoveFromCart Events
    public func removeCartEvent(queryParams: RequestQueryParams!, rmCartQueryParams:CartQueryParams? = nil) async {
        CroboxAPIServices.shared.socket(eventType: .RemoveCart, additionalParams: rmCartQueryParams, queryParams: queryParams) { result in
            switch result {
            case .success(_):
                ()
            case let .failure(error):
                print(error)
            }
        }
    }
    
    /// For reporting a general-purpose error event
    ///
    /// - Parameter queryParams: Common query parameters, shared by the requests sent from the same page view
    /// - Parameter errorQueryParams: Event specific query parameters for Error Events
    public func errorEvent(queryParams: RequestQueryParams!, errorQueryParams:ErrorQueryParams? = nil) async {
        CroboxAPIServices.shared.socket(eventType: .Error, additionalParams: errorQueryParams, queryParams: queryParams) {result in
            switch result {
            case .success(_):
                ()
            case let .failure(error):
                print(error)
            }
        }
    }
    
    /// For reporting custom events
    ///
    /// - Parameter queryParams: Common query parameters, shared by the requests sent from the same page view
    /// - Parameter customQueryParams: Event specific query parameters for Custom Events
    public func customEvent(queryParams: RequestQueryParams!, customQueryParams:CustomQueryParams? = nil) async {
        CroboxAPIServices.shared.socket(eventType: .CustomEvent, additionalParams: customQueryParams, queryParams: queryParams) { result in
            switch result {
            case .success(_):
                ()
            case let .failure(error):
                print(error)
            }
        }
    }
    
    /// For retrieval of Promotions
    ///
    ///  - Note A Placeholder represent a predesignated point on the user interface, where the promotion will be located and displayed. Placeholders are linked with Campaigns which has all promotion attributes, UI components, messages, time frame etc. These are all managed via the Crobox Admin application.
    ///
    /// - Parameter placeholderId: Identifier of the placeholder
    /// - Parameter queryParams: Common query parameters, shared by the requests sent from the same page view
    /// - TODO Parameter impressions: List of product ID's which promotions are requested for. It may be empty for the pages where products are not involved. (e.g. Checkout page)
    /// - Parameter closure: The callback to be notified for the response or if an error occurs before, during or after the request is sent
    public func promotions(placeholderId:String!,
                           queryParams: RequestQueryParams!,
                           productIds: Set<String>? = Set(),
                           closure: @escaping (_ result: Result<PromotionResponse, CroboxError>) -> Void) async {
        CroboxAPIServices.shared.promotions(placeholderId: placeholderId, queryParams: queryParams, productIds: productIds, closure: closure)
    }
}


import Foundation

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
    public func clickEvent(queryParams: RequestQueryParams!, clickQueryParams:ClickQueryParams? = nil) {
        Task {
            do {
                try await CroboxAPIServices.shared.event(eventType: .Click, additionalParams: clickQueryParams, queryParams: queryParams)
            } catch {
                if (Crobox.shared.isDebug) {
                    print(error)
                }
                errorEvent(queryParams: queryParams, errorQueryParams: ErrorQueryParams(tag: "sdk", name: "click", message: "\(error)"))
            }
        }
    }
    
    /// For sending an Add To Cart Event, to track the metrics of customer's intention of making a purchase.
    ///
    /// - Parameter queryParams: Common query parameters, shared by the requests sent from the same page view
    /// - Parameter addCartQueryParams: Event specific query parameters for AddToCart and RemoveFromCart Events
    public func addCartEvent(queryParams: RequestQueryParams!, addCartQueryParams:CartQueryParams? = nil) {
        Task {
            do {
                try await CroboxAPIServices.shared.event(eventType: .AddCart, additionalParams: addCartQueryParams, queryParams: queryParams)
            } catch {
                if (Crobox.shared.isDebug) {
                    print(error)
                }
                errorEvent(queryParams: queryParams, errorQueryParams: ErrorQueryParams(tag: "sdk", name: "addcart", message: "\(error)"))
            }
        }
    }
    
    /// For sending an Remove From Cart Event, to track the metrics of product's removal from a purchase.
    ///
    /// - Parameter queryParams: Common query parameters, shared by the requests sent from the same page view
    /// - Parameter rmCartQueryParams: Event specific query parameters for AddToCart and RemoveFromCart Events
    public func removeCartEvent(queryParams: RequestQueryParams!, rmCartQueryParams:CartQueryParams? = nil) {
        Task {
            do {
                try await CroboxAPIServices.shared.event(eventType: .RemoveCart, additionalParams: rmCartQueryParams, queryParams: queryParams)
            } catch {
                if (Crobox.shared.isDebug) {
                    print(error)
                }
                errorEvent(queryParams: queryParams, errorQueryParams: ErrorQueryParams(tag: "sdk", name: "rmcart", message: "\(error)"))
            }
        }
    }
    
    
    /// For reporting a general-purpose error event
    ///
    /// - Parameter queryParams: Common query parameters, shared by the requests sent from the same page view
    /// - Parameter errorQueryParams: Event specific query parameters for Error Events
    public func errorEvent(queryParams: RequestQueryParams!, errorQueryParams:ErrorQueryParams? = nil) {
        Task {
            do {
                try await CroboxAPIServices.shared.event(eventType: .Error, additionalParams: errorQueryParams, queryParams: queryParams)
            } catch {
                if (Crobox.shared.isDebug) {
                    print(error)
                }
            }
        }
    }
    
    /// For reporting custom events
    ///
    /// - Parameter queryParams: Common query parameters, shared by the requests sent from the same page view
    /// - Parameter customQueryParams: Event specific query parameters for Custom Events
    public func customEvent(queryParams: RequestQueryParams!, customQueryParams:CustomQueryParams? = nil) {
        Task {
            do {
                try await CroboxAPIServices.shared.event(eventType: .CustomEvent, additionalParams: customQueryParams, queryParams: queryParams)
            } catch {
                if (Crobox.shared.isDebug) {
                    print(error)
                }
                errorEvent(queryParams: queryParams, errorQueryParams: ErrorQueryParams(tag: "sdk", name: "custom", message: "\(error)"))
            }
        }
    }
    
    /// For reporting page view events
    ///
    /// - Parameter queryParams: Common query parameters, shared by the requests sent from the same page view
    /// - Parameter pageViewParams: Event specific query parameters for Page View Events
    public func pageViewEvent(queryParams: RequestQueryParams!, pageViewParams:PageViewParams? = nil) {
        Task {
            do {
                try await CroboxAPIServices.shared.event(eventType: .PageView, additionalParams: pageViewParams, queryParams: queryParams)
            } catch {
                if (Crobox.shared.isDebug) {
                    print(error)
                }
                errorEvent(queryParams: queryParams, errorQueryParams: ErrorQueryParams(tag: "sdk", name: "pageview", message: "\(error)"))
            }
        }
    }
    
    /// For reporting checkout events
    ///
    /// - Parameter queryParams: Common query parameters, shared by the requests sent from the same page view
    /// - Parameter checkoutParams: Event specific query parameters for Checkout Events
    public func checkoutEvent(queryParams: RequestQueryParams!, checkoutParams: CheckoutParams? = nil) {
        Task {
            do {
                try await CroboxAPIServices.shared.event(eventType: .Checkout, additionalParams: checkoutParams, queryParams: queryParams)
            } catch {
                if (Crobox.shared.isDebug) {
                    print(error)
                }
                errorEvent(queryParams: queryParams, errorQueryParams: ErrorQueryParams(tag: "sdk", name: "checkout", message: "\(error)"))
            }
        }
    }
    
    /// For reporting purchase events
    ///
    /// - Parameter queryParams: Common query parameters, shared by the requests sent from the same page view
    /// - Parameter purchaseParams: Event specific query parameters for Purchase Events
    public func purchaseEvent(queryParams: RequestQueryParams!, purchaseParams: PurchaseParams? = nil) {
        Task {
            do {
                try await CroboxAPIServices.shared.event(eventType: .Purchase, additionalParams: purchaseParams, queryParams: queryParams)
            } catch {
                if (Crobox.shared.isDebug) {
                    print(error)
                }
                errorEvent(queryParams: queryParams, errorQueryParams: ErrorQueryParams(tag: "sdk", name: "purchase", message: "\(error)"))
            }
        }
    }
    
    
    /// For retrieval of Promotions
    ///
    ///  - Note A Placeholder represent a predesignated point on the user interface, where the promotion will be located and displayed. Placeholders are linked with Campaigns which has all promotion attributes, UI components, messages, time frame etc. These are all managed via the Crobox Admin application.
    ///
    /// - Parameter placeholderId: Identifier of the placeholder
    /// - Parameter queryParams: Common query parameters, shared by the requests sent from the same page view
    /// - Parameter productIds: List of product ID's which promotions are requested for. It may be empty for the pages where products are not involved. (e.g. Checkout page)
    public func promotions(placeholderId:String!,
                           queryParams: RequestQueryParams!,
                           productIds: Set<String>? = Set()) async -> Result<PromotionResponse, CroboxErrors> {
        do {
            let response = try await CroboxAPIServices.shared.promotions(placeholderId: placeholderId, queryParams: queryParams, productIds: productIds)
            return .success(response)
        } catch {
            if (Crobox.shared.isDebug) {
                print(error)
            }
            errorEvent(queryParams: queryParams, errorQueryParams: ErrorQueryParams(tag: "sdk", name:"promotions", message: "\(error)"))
            switch error {
            case is CroboxErrors:
                return .failure(error as! CroboxErrors)
            default:
                return .failure(CroboxErrors.internalError(msg: "Promotion request failure", cause: error))
            }
        }
    }
    
}

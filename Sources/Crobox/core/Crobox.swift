
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
        send(.Click, name: "click", additionalParams: clickQueryParams, queryParams: queryParams)
    }
    
    /// For sending an Add To Cart Event, to track the metrics of customer's intention of making a purchase.
    ///
    /// - Parameter queryParams: Common query parameters, shared by the requests sent from the same page view
    /// - Parameter addCartQueryParams: Event specific query parameters for AddToCart and RemoveFromCart Events
    public func addCartEvent(queryParams: RequestQueryParams!, addCartQueryParams:CartQueryParams? = nil) {
        send(.AddCart, name: "addcart", additionalParams: addCartQueryParams, queryParams: queryParams)
    }
    
    /// For sending an Remove From Cart Event, to track the metrics of product's removal from a purchase.
    ///
    /// - Parameter queryParams: Common query parameters, shared by the requests sent from the same page view
    /// - Parameter rmCartQueryParams: Event specific query parameters for AddToCart and RemoveFromCart Events
    public func removeCartEvent(queryParams: RequestQueryParams!, rmCartQueryParams:CartQueryParams? = nil) {
        send(.RemoveCart, name: "rmcart", additionalParams: rmCartQueryParams, queryParams: queryParams)
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
        send(.CustomEvent, name: "custom", additionalParams: customQueryParams, queryParams: queryParams)
    }
    
    /// For reporting page view events
    ///
    /// - Parameter queryParams: Common query parameters, shared by the requests sent from the same page view
    /// - Parameter pageViewParams: Event specific query parameters for Page View Events
    public func pageViewEvent(queryParams: RequestQueryParams!, pageViewParams:PageViewParams? = nil) {
        send(.PageView, name: "pageview", additionalParams: pageViewParams, queryParams: queryParams)
    }
    
    /// For reporting checkout events
    ///
    /// - Parameter queryParams: Common query parameters, shared by the requests sent from the same page view
    /// - Parameter checkoutParams: Event specific query parameters for Checkout Events
    public func checkoutEvent(queryParams: RequestQueryParams!, checkoutParams: CheckoutParams? = nil) {
        send(.Checkout, name: "checkout", additionalParams: checkoutParams, queryParams: queryParams)
    }
    
    /// For reporting purchase events
    ///
    /// - Parameter queryParams: Common query parameters, shared by the requests sent from the same page view
    /// - Parameter purchaseParams: Event specific query parameters for Purchase Events
    public func purchaseEvent(queryParams: RequestQueryParams!, purchaseParams: PurchaseParams? = nil) {
        send(.Purchase, name: "purchase", additionalParams: purchaseParams, queryParams: queryParams)
    }
    
    
    /// For retrieval of Promotions
    ///
    ///  - Note A Placeholder represent a predesignated point on the user interface, where the promotion will be located and displayed. Placeholders are linked with Campaigns which has all promotion attributes, UI components, messages, time frame etc. These are all managed via the Crobox Admin application.
    ///
    /// - Parameter placeholderId: Identifier of the placeholder
    /// - Parameter queryParams: Common query parameters, shared by the requests sent from the same page view
    /// - Parameter productIds: List of product ID's which promotions are requested for, in the order they are displayed. The server ranks promotions in this order. It may be empty for the pages where products are not involved. (e.g. Checkout page)
    public func promotions(placeholderId:String!,
                           queryParams: RequestQueryParams!,
                           productIds: [String]? = []) async -> Result<PromotionResponse, CroboxErrors> {
        do {
            let response = try await CroboxAPIServices.shared.promotions(placeholderId: placeholderId, queryParams: queryParams, productIds: productIds)
            return .success(response)
        } catch {
            if (Crobox.shared.isDebug) {
                print(error)
            }
            // A cancelled request (e.g. a SwiftUI `.task` that went away) is not an error
            if !Crobox.isCancellation(error) {
                errorEvent(queryParams: queryParams, errorQueryParams: ErrorQueryParams(tag: "sdk", name:"promotions", message: Crobox.errorMessage(error)))
            }
            switch error {
            case is CroboxErrors:
                return .failure(error as! CroboxErrors)
            default:
                return .failure(CroboxErrors.internalError(msg: "Promotion request failure", cause: error))
            }
        }
    }
    
    private func send(_ eventType: EventType, name: String, additionalParams: Any?, queryParams: RequestQueryParams!) {
        Task {
            do {
                try await CroboxAPIServices.shared.event(eventType: eventType, additionalParams: additionalParams, queryParams: queryParams)
            } catch {
                if (Crobox.shared.isDebug) {
                    print(error)
                }
                if !Crobox.isCancellation(error) {
                    errorEvent(queryParams: queryParams, errorQueryParams: ErrorQueryParams(tag: "sdk", name: name, message: Crobox.errorMessage(error)))
                }
            }
        }
    }

    /// Whether the error means the request was cancelled, rather than that it failed
    static func isCancellation(_ error: Error) -> Bool {
        switch error {
        case is CancellationError:
            return true
        case let urlError as URLError:
            return urlError.code == .cancelled
        case CroboxErrors.internalError(_, let cause):
            return isCancellation(cause)
        default:
            return false
        }
    }

    /// A description of the error for error events. Unlike `"\(error)"`, it leaves out the request URL,
    /// which carries the user id and custom properties.
    static func errorMessage(_ error: Error) -> String {
        switch error {
        case let urlError as URLError:
            return "URLError(\(urlError.code.rawValue)): \(urlError.localizedDescription)"
        case CroboxErrors.internalError(let msg, let cause):
            return "internalError(\(msg)): \(errorMessage(cause))"
        case is CroboxErrors:
            return "\(error)"
        default:
            let nsError = error as NSError
            return "\(nsError.domain)(\(nsError.code)): \(nsError.localizedDescription)"
        }
    }
    
}

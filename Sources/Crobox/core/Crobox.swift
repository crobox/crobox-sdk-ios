
import Foundation

public class Crobox {
    
    /*
     CroboxSDK instance
     */
    public static let shared = Crobox()
    
    /*
     enable or disable logging. Prints errors if enabled
     */
    public var isLoggingEnabled = false
    
    /*
     mandatory for common configuration parameters
     */
    public var config:CroboxConfig!
    
    
    public func configure(_ config:CroboxConfig) {
        self.config =  config
    }
    
    /// For sending a Click Event, to track the ratio of visits on impressions.
    ///
    /// - Note: Click events forms the measurement data for Click-through rate (CTR) for campaigns.
    ///
    /// - Parameter view: Common parameters, shared by the requests sent from the same view
    /// - Parameter params: Event specific parameters for Click Events
    public func clickEvent(view: ViewContext, params: ClickParams? = nil) {
        send(.Click, name: "click", params: params, view: view)
    }
    
    /// For sending an Add To Cart Event, to track the metrics of customer's intention of making a purchase.
    ///
    /// - Parameter view: Common parameters, shared by the requests sent from the same view
    /// - Parameter params: Event specific parameters for AddToCart and RemoveFromCart Events
    public func addToCartEvent(view: ViewContext, params: CartParams? = nil) {
        send(.AddCart, name: "addcart", params: params, view: view)
    }
    
    /// For sending an Remove From Cart Event, to track the metrics of product's removal from a purchase.
    ///
    /// - Parameter view: Common parameters, shared by the requests sent from the same view
    /// - Parameter params: Event specific parameters for AddToCart and RemoveFromCart Events
    public func removeFromCartEvent(view: ViewContext, params: CartParams? = nil) {
        send(.RemoveCart, name: "rmcart", params: params, view: view)
    }
    
    
    /// For reporting a general-purpose error event
    ///
    /// - Parameter view: Common parameters, shared by the requests sent from the same view
    /// - Parameter params: Event specific parameters for Error Events
    public func errorEvent(view: ViewContext, params: ErrorParams? = nil) {
        Task {
            do {
                try await CroboxAPIServices.shared.event(eventType: .Error, params: params, view: view)
            } catch {
                if (Crobox.shared.isLoggingEnabled) {
                    print(error)
                }
            }
        }
    }
    
    /// For reporting custom events
    ///
    /// - Parameter view: Common parameters, shared by the requests sent from the same view
    /// - Parameter params: Event specific parameters for Custom Events
    public func customEvent(view: ViewContext, params: CustomEventParams? = nil) {
        send(.CustomEvent, name: "custom", params: params, view: view)
    }
    
    /// For reporting view events
    ///
    /// - Parameter view: Common parameters, shared by the requests sent from the same view
    /// - Parameter params: Event specific parameters for View Events
    public func viewEvent(view: ViewContext, params: ViewParams? = nil) {
        send(.PageView, name: "pageview", params: params, view: view)
    }
    
    /// For reporting checkout events
    ///
    /// - Parameter view: Common parameters, shared by the requests sent from the same view
    /// - Parameter params: Event specific parameters for Checkout Events
    public func checkoutEvent(view: ViewContext, params: CheckoutParams? = nil) {
        send(.Checkout, name: "checkout", params: params, view: view)
    }
    
    /// For reporting purchase events
    ///
    /// - Parameter view: Common parameters, shared by the requests sent from the same view
    /// - Parameter params: Event specific parameters for Purchase Events
    public func purchaseEvent(view: ViewContext, params: PurchaseParams? = nil) {
        send(.Purchase, name: "purchase", params: params, view: view)
    }
    
    
    /// For retrieval of Promotions
    ///
    ///  - Note A Placement represents a predesignated point on the user interface, where the promotion will be located and displayed. Placements are linked with Campaigns which has all promotion attributes, UI components, messages, time frame etc. These are all managed via the Crobox Admin application.
    ///
    /// - Parameter placementId: Identifier of the placement
    /// - Parameter view: Common parameters, shared by the requests sent from the same view
    /// - Parameter productIds: List of product ID's which promotions are requested for, in the order they are displayed. The server ranks promotions in this order. It may be empty for the views where products are not involved. (e.g. Checkout view)
    public func promotions(placementId: String,
                           view: ViewContext,
                           productIds: [String] = []) async -> Result<PromotionsResponse, CroboxError> {
        do {
            let response = try await CroboxAPIServices.shared.promotions(placementId: placementId, view: view, productIds: productIds)
            return .success(response)
        } catch {
            if (Crobox.shared.isLoggingEnabled) {
                print(error)
            }
            // A cancelled request (e.g. a SwiftUI `.task` that went away) is not an error
            if !Crobox.isCancellation(error) {
                errorEvent(view: view, params: ErrorParams(tag: "sdk", name:"promotions", message: Crobox.errorMessage(error)))
            }
            switch error {
            case is CroboxError:
                return .failure(error as! CroboxError)
            default:
                return .failure(CroboxError.internalError(msg: "Promotion request failure", cause: error))
            }
        }
    }
    
    private func send(_ eventType: EventType, name: String, params: Any?, view: ViewContext) {
        Task {
            do {
                try await CroboxAPIServices.shared.event(eventType: eventType, params: params, view: view)
            } catch {
                if (Crobox.shared.isLoggingEnabled) {
                    print(error)
                }
                if !Crobox.isCancellation(error) {
                    errorEvent(view: view, params: ErrorParams(tag: "sdk", name: name, message: Crobox.errorMessage(error)))
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
        case CroboxError.internalError(_, let cause):
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
        case CroboxError.internalError(let msg, let cause):
            return "internalError(\(msg)): \(errorMessage(cause))"
        case is CroboxError:
            return "\(error)"
        default:
            let nsError = error as NSError
            return "\(nsError.domain)(\(nsError.code)): \(nsError.localizedDescription)"
        }
    }
    
}


import Foundation

/**
 * Common parameters for all requests sent from the same page view.
 *
 *  @param viewId : Unique identifier for a unique page viewing, reused between various event and promotion requests from the same page. It must be refreshed when a user goes to another page or reloads the same page.
 *  @param pageType : One of the values in predefined list of types of pages of the whole e-commerce funnel
 *  @param customProperties : Free format custom properties to be forwarded to Crobox endpoints, for example to help identifying certain traits of a visitor. Example: Map("mobileUser", "yes")
 *  @param pageName : Free format Page Name if exists
 */

public class RequestQueryParams {
    public let viewId: UUID
    public var pageType: PageType?
    public var customProperties: [String: String]?
    public var pageName: String?
    
    private var counter: Int = 0
    
    public init(viewId: UUID,
                pageType: PageType? = nil,
                customProperties: [String: String]? = nil,
                pageName: String? = nil) {
        self.viewId = viewId
        self.pageType = pageType
        self.customProperties = customProperties
        self.pageName = pageName
    }
    
    public func viewCounter() -> Int {
        let currentCount = counter
        counter += 1
        return currentCount
    }
}

public enum PageType:Int{
    case PageOther = 0
    case PageIndex = 1
    case PageOverview = 2
    case PageDetail = 3
    case PageCart = 4
    case PageCheckout = 5
    case PageComplete = 6
    case PageSearch = 7
}

public enum EventType:String{
    case Click = "click" // Click
    case AddCart = "cart" // Add to Shopping Cart
    case RemoveCart = "rmcart" // Remove from Shopping Cart
    case PageView = "pageview" // PageView
    case Error = "error" // Error
    case CustomEvent = "event" // CustomEvent
}

/**
 * Type specific parameters for Error events
 *
 *  @param tag : Free tagging for error categorisation
 *  @param name : Error name, if available
 *  @param message : Error message, if available
 *  @param file : File name, if available
 *  @param line : Line number, if available
 */

public struct ErrorQueryParams {
    public var tag: String?
    public var name: String?
    public var message: String?
    public var file: String?
    public var line: Int?
    public var devicePixelRatio: Double?
    public var deviceLanguage: String?
    public var viewPortSize: String?
    public var screenResolutionSize: String?
}

/**
 * Type specific parameters for click events
 *
 *  @param productId : Unique identifier for a product
 *  @param price : Product price, if available
 *  @param quantity : Quantity, if available
 */

public struct ClickQueryParams {
    public var productId: String?
    public var category: String?
    public var price: Double?
    public var quantity: Int?
    
    // Public initializer
    public init(productId: String? = nil,
                category: String? = nil,
                price: Double? = nil,
                quantity: Int? = nil) {
        
        self.productId = productId
        self.category = category
        self.price = price
        self.quantity = quantity
    }
}


/**
 * Type specific parameters for Add/Remove Cart events
 *
 *  @param productId : Unique identifier for a product
 *  @param price : Product price, if available
 *  @param quantity : Quantity, if available
 */

public struct CartQueryParams {
    public var productId: String?
    public var category: String?
    public var price: Double?
    public var quantity: Int?
    
    // Public initializer
    public init(productId: String? = nil,
                category: String? = nil,
                price: Double? = nil,
                quantity: Int? = nil) {
        
        self.productId = productId
        self.category = category
        self.price = price
        self.quantity = quantity
    }
}

/**
 * Type specific parameters for general-purpose Custom events
 *
 *  @param name : Event name
 *  @param promotionId : Promotion Id, if available
 *  @param productId : Unique identifier for a product
 *  @param price : Product price, if available
 *  @param quantity : Quantity, if available
 */

public struct CustomQueryParams {
    var name: String?
    var promotionId: UUID?
    var productId: Double?
    var category: Int?
    var price: Double?
    var quantity: Int?
    
    // Public initializer
    public init(name: String? = nil,
                promotionId: UUID? = nil,
                productId: Double? = nil,
                category: Int? = nil,
                price: Double? = nil,
                quantity: Int? = nil) {
        
        self.name = name
        self.promotionId = promotionId
        self.productId = productId
        self.category = category
        self.price = price
        self.quantity = quantity
    }
}

//TODO
struct ClickEvent {
    var pageType: String?
    var pageTitle: String?
    var productId: ProductId?
    var impressions: Int?
    var clientLoadStartTime: Date?
    var clientLoadDuration: TimeInterval?
    var referrerUrl: URL?
    var pageUrl: URL?
    var searchTerms: String?
    var historyLength: Int?
    var step: Step?
    var transactionId: TransactionId?
    
    struct ProductId {
        var id: String
        var category: String?
        var productList: [String]?
        
        init(id: String, category: String? = nil, productList: [String]? = nil) {
            self.id = id
            self.category = category
            self.productList = productList
        }
    }
    
    struct Step {
        var choice: String?
        init(choice: String? = nil) {
            self.choice = choice
        }
    }
    
    struct TransactionId {
        var id: String
        var revenue: Double?
        var coupon: String?
        var affiliation: String?
        
        init(id: String, revenue: Double? = nil, coupon: String? = nil, affiliation: String? = nil) {
            self.id = id
            self.revenue = revenue
            self.coupon = coupon
            self.affiliation = affiliation
        }
    }
}


/**
 * Configuration parameters for all requests
 *
 *  @param containerId : This is the unique id of the Crobox Container as it is generated and assigned by Crobox.
 *  @param visitorId : This is a randomly generated id that identifies a visitor / user. It must be the same across the user session (or even longer when possible).
 *  @param currencyCode : Contains information about the valid currency. It must be uppercase, three-letter form of ISO 4217 currency codes. It is useful if there are more than one currency configured in the Crobox Container.
 *  @param localeCode : Locale code combination for the localization,
 *  @param userId : It is an identifier that allows coupling between Crobox user profiles with the client's user profiles, if available.
 *  @param timezone : Timezone
 *  @param customProperties : Free format custom properties to be forwarded to Crobox endpoints with each request, for example to help identifying certain traits of a visitor. Example: Map("mobileUser", "yes")
 */

public struct CroboxConfig {
    let containerId: String
    let visitorId: UUID
    var currencyCode: String? = nil
    var localeCode: LocaleCode? = nil
    var userId: String? = nil
    var timezone: Int? = nil
    var customProperties: [String: String]? = nil
}

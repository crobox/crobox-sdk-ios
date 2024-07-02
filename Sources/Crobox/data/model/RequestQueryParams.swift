
import Foundation

public class RequestQueryParams {
    public let viewId: UUID
    public var pageType: PageType?
    public var customProperties: [String: String]?
    public var pageName: String?
    
    private var counter: Int = 0

    /**
     Common parameters for all requests sent from the same page view.
     
     - parameter viewId: Unique identifier for a unique page viewing, reused between various event and promotion requests from the same page. It must be refreshed when a user goes to another page or reloads the same page.
     - parameter pageType: One of the values in predefined list of types of pages of the whole e-commerce funnel
     - parameter customProperties: Free format custom properties to be forwarded to Crobox endpoints, for example to help identifying certain traits of a visitor. Example: Map("mobileUser", "yes")
     - parameter pageName: Free format Page Name if exists
     */
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
 Type specific parameters for Error events
 
 - parameter tag: Free tagging for error categorisation
 - parameter name: Error name, if available
 - parameter message: Error message, if available
 - parameter file: File name, if available
 - parameter line : Line number, if available
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

public struct ClickQueryParams {
    public var productId: String?
    public var category: String?
    public var price: Double?
    public var quantity: Int?
    
    /**
     Type specific parameters for click events
     
     - parameter productId: Unique identifier for a product
     - parameter price: Product price, if available
     - parameter quantity: Quantity, if available
     */
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
 Type specific parameters for Add/Remove Cart events
 
 - parameter productId: Unique identifier for a product
 - parameter price: Product price, if available
 - parameter quantity: Quantity, if available
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

public struct CustomQueryParams {
    var name: String?
    var promotionId: UUID?
    var productId: Double?
    var category: Int?
    var price: Double?
    var quantity: Int?
    
    /**
     Type specific parameters for general-purpose Custom events
     
     - parameter name: Event name
     - parameter promotionId: Promotion Id, if available
     - parameter productId: Unique identifier for a product
     - parameter price: Product price, if available
     - parameter quantity: Quantity, if available
     */
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

public struct CroboxConfig {
    public let containerId: String
    public let visitorId: UUID
    public var currencyCode: String?
    public var localeCode: LocaleCode?
    public var userId: String?
    public var timezone: Int?
    public var customProperties: [String: String]?

    /**
     Common Configuration parameters for all requests
     
     - parameter containerId: This is the unique id of the Crobox Container as it is generated and assigned by Crobox.
     - parameter visitorId: This is a randomly generated id that identifies a visitor / user. It must be the same across the user session (or even longer when possible).
     - parameter currencyCode: Contains information about the valid currency. It must be uppercase, three-letter form of ISO 4217 currency codes. It is useful if there are more than one currency configured in the Crobox Container.
     - parameter localeCode: Locale code combination for the localization,
     - parameter userId: It is an identifier that allows coupling between Crobox user profiles with the client's user profiles, if available.
     - parameter timezone: Timezone
     - parameter customProperties: Free format custom properties to be forwarded to Crobox endpoints with each request, for example to help identifying certain traits of a visitor. Example: Map("mobileUser", "yes")
     */
    public init(containerId: String, visitorId: UUID, currencyCode: String? = nil, localeCode: LocaleCode? = nil, userId: String? = nil, timezone: Int? = nil, customProperties: [String: String]? = nil) {
        self.containerId = containerId
        self.visitorId = visitorId
        self.currencyCode = currencyCode
        self.localeCode = localeCode
        self.userId = userId
        self.timezone = timezone
        self.customProperties = customProperties
    }
}

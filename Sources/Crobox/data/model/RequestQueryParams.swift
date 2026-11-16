
import Foundation

/**
 Common parameters for all requests sent from the same page view.
 
 - parameter viewId: Unique identifier for a unique page viewing, reused between various event and promotion requests from the same page. It must be refreshed when a user goes to another page or reloads the same page.
 - parameter pageType: One of the values in predefined list of types of pages of the whole e-commerce funnel
 - parameter customProperties: Free format custom properties to be forwarded to Crobox endpoints, for example to help identifying certain traits of a visitor. Example: Map("mobileUser", "yes")
 - parameter pageName: Free format Page Name if exists
 */
public class RequestQueryParams {
    public let viewId: UUID
    public var pageType: PageType
    public var customProperties: [String: String]?
    public var pageName: String?
    
    // Events from the same view are deduplicated on the counter, so it must never hand out
    // the same value twice, even when requests are sent from concurrent tasks.
    private var counter: Int = 0
    private let counterLock = NSLock()

    public init(viewId: UUID,
                pageType: PageType,
                customProperties: [String: String]? = nil,
                pageName: String? = nil) {
        self.viewId = viewId
        self.pageType = pageType
        self.customProperties = customProperties
        self.pageName = pageName
    }
    
    public func viewCounter() -> Int {
        counterLock.lock()
        defer { counterLock.unlock() }
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
    case Checkout = "checkout" // Checkout
    case Purchase = "purchase" // Purchase
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

    public init(tag: String? = nil,
                name: String? = nil,
                message: String? = nil,
                file: String? = nil,
                line: Int? = 0) {
        self.tag = tag
        self.name = name
        self.message = message
        self.file = file
        self.line = line
    }
}

/**
 Type specific parameters for click events
 
 - parameter productId: Unique identifier for a product
 - parameter quantity: Quantity, if available
 
 The price is not sent: Crobox takes it from the product catalog.
 */
public struct ClickQueryParams {
    public var productId: String?
    public var quantity: Int?
    
    public init(productId: String? = nil,
                quantity: Int? = nil) {
        
        self.productId = productId
        self.quantity = quantity
    }
}

/**
 Type specific parameters for Add/Remove Cart events
 
 - parameter productId: Unique identifier for a product
 - parameter quantity: Quantity, if available
 
 The price is not sent: Crobox takes it from the product catalog.
 */
public struct CartQueryParams {
    public var productId: String?
    public var quantity: Int?
    
    public init(productId: String? = nil,
                quantity: Int? = nil) {
        
        self.productId = productId
        self.quantity = quantity
    }
}

/**
 Type specific parameters for general-purpose Custom events
 
 - parameter name: Event name
 - parameter promotionId: Promotion Id, if available
 - parameter productId: Unique identifier for a product
 - parameter quantity: Quantity, if available
 
 The price is not sent: Crobox takes it from the product catalog.
 */
public struct CustomQueryParams {
    var name: String?
    var promotionId: UUID?
    var productId: String?
    var quantity: Int?
    
    public init(name: String? = nil,
                promotionId: UUID? = nil,
                productId: String? = nil,
                quantity: Int? = nil) {
        
        self.name = name
        self.promotionId = promotionId
        self.productId = productId
        self.quantity = quantity
    }
}

/**
 Product specific parameters for various events
 
 - parameter productId Product identifier
 - parameter quantity Optional quantity, e.g. of a purchased product
 - parameter list Optional name of the list the product is shown in, e.g. "search results" or "related products"
 
 The price is not sent: Crobox takes it from the product catalog. The position of an impression is its position in the list it is passed in.
 */
public struct ProductParams {
    var productId: String?
    var quantity: Int?
    var list: String?
    
    public init(productId: String? = nil,
                quantity: Int? = nil,
                list: String? = nil
    ) {
        self.productId = productId
        self.quantity = quantity
        self.list = list
    }
}

/**
 Type specific parameters for Page View events

 - parameter pageTitle: Title of the page, if available
 - parameter product: The product of a product detail page
 - parameter searchTerms: Search terms of a search results page
 - parameter impressions: The products shown on the page, in the order they are shown
 - parameter customProperties: Optional set of general purpose custom properties
 */
public struct PageViewParams {
    var pageTitle: String?
    var product: ProductParams?
    var searchTerms: String?
    var impressions: [ProductParams]?
    var customProperties: [String : String]?
    
    public init(pageTitle: String?,
                product: ProductParams?,
                searchTerms: String?,
                impressions: [ProductParams]?,
                customProperties: [String : String]?
    ) {
        self.pageTitle = pageTitle
        self.product = product
        self.searchTerms = searchTerms
        self.impressions = impressions
        self.customProperties = customProperties
    }
}

/**
 Type specific parameters for Checkout events
 
 - parameter products: Optional set of products to be purchased
 - parameter step: Optional number of the step in the checkout process (e.g. "1"). The server reads it as an integer.
 - parameter customProperties Optional set of general purpose custom properties, for example to help identifying certaion traits of the page
 */
public struct CheckoutParams {
    var products: [ProductParams]?
    var step: String?
    var customProperties: [String : String]?
    
    public init(products: [ProductParams]?,
                step: String?,
                customProperties: [String : String]?
    ) {
        self.products = products
        self.step = step
        self.customProperties = customProperties
    }
}

/**
 Type specific parameters for Purchase events
 
 - parameter products: Optional set of products purchased
 - parameter transactionId: Transaction identifier. Crobox only records a purchase with one, and counts each transaction once per visitor.
 - parameter affiliation The store or affiliation from which this transaction occurred (e.g. Google Store), if available
 - parameter coupon Coupon, if available
 - parameter revenue The total associated with the transaction, in the currency of the locale. Without it, Crobox adds up the catalog prices of the products.
 - parameter customProperties Optional set of general purpose custom properties, for example to help identifying certaion traits of the page
 */
public struct PurchaseParams {
    var products: [ProductParams]?
    var transactionId: String
    var affiliation: String?
    var coupon: String?
    var revenue: Double?
    var customProperties: [String : String]?
    
    public init(products: [ProductParams]?,
                transactionId: String,
                affiliation: String?,
                coupon: String?,
                revenue: Double?,
                customProperties: [String : String]?
    ) {
        self.products = products
        self.transactionId = transactionId
        self.affiliation = affiliation
        self.coupon = coupon
        self.revenue = revenue
        self.customProperties = customProperties
    }
}

/**
 Common Configuration parameters for all requests
 
 - parameter containerId: This is the unique id of the Crobox Container as it is generated and assigned by Crobox.
 - parameter visitorId: This is a randomly generated id that identifies a visitor / user. It must stay the same across app launches: campaign and control assignment is keyed on it, so a new id on every launch re-buckets the user. Use `CroboxConfig.persistentVisitorId()` unless the app already stores its own id.
 - parameter localeCode: Locale code combination for the localization. Crobox picks the region (country, language and currency) of the Container from it, so in a Container with several regions it must be set to the region the user is shopping in.
 - parameter userId: It is an identifier that allows coupling between Crobox user profiles with the client's user profiles, if available.
 - parameter timezone: Time zone of the visitor, to use instead of the device's, for example `TimeZone(identifier: "Europe/Amsterdam")`. It is sent as its offset from UTC in hours at the time of each request. When nil, the device's time zone is used.
 - parameter customProperties: Free format custom properties to be forwarded to Crobox endpoints with each request, for example to help identifying certain traits of a visitor. Example: Map("mobileUser", "yes")
 */
public struct CroboxConfig {
    public let containerId: String
    public let visitorId: UUID
    public var localeCode: LocaleCode?
    public var userId: String?
    public var timezone: TimeZone?
    public var customProperties: [String: String]?

    public init(containerId: String, visitorId: UUID, localeCode: LocaleCode? = nil, userId: String? = nil, timezone: TimeZone? = nil, customProperties: [String: String]? = nil) {
        self.containerId = containerId
        self.visitorId = visitorId
        self.localeCode = localeCode
        self.userId = userId
        self.timezone = timezone
        self.customProperties = customProperties
    }

    /// Returns a visitor id that is stored in `UserDefaults` and stays the same across app launches.
    /// A new id is created and stored on first use.
    public static func persistentVisitorId(defaults: UserDefaults = .standard) -> UUID {
        return Preferences(defaults: defaults).visitorId()
    }

    /// Forgets the stored visitor id, for example when the user logs out.
    /// The next call to `persistentVisitorId()` returns a new id.
    public static func resetPersistentVisitorId(defaults: UserDefaults = .standard) {
        Preferences(defaults: defaults).resetVisitorId()
    }
}

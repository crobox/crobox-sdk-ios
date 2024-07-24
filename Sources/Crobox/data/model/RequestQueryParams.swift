
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
    
    private var counter: Int = 0

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
 - parameter price: Product price, if available
 - parameter quantity: Quantity, if available
 */
public struct ClickQueryParams {
    public var productId: String?
    public var price: Double?
    public var quantity: Int?
    
    public init(productId: String? = nil,
                price: Double? = nil,
                quantity: Int? = nil) {
        
        self.productId = productId
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
    public var price: Double?
    public var quantity: Int?
    
    
    public init(productId: String? = nil,
                price: Double? = nil,
                quantity: Int? = nil) {
        
        self.productId = productId
        self.price = price
        self.quantity = quantity
    }
}

/**
 Type specific parameters for general-purpose Custom events
 
 - parameter name: Event name
 - parameter promotionId: Promotion Id, if available
 - parameter productId: Unique identifier for a product
 - parameter price: Product price, if available
 - parameter quantity: Quantity, if available
 */
public struct CustomQueryParams {
    var name: String?
    var promotionId: UUID?
    var productId: String?
    var price: Double?
    var quantity: Int?
    
    public init(name: String? = nil,
                promotionId: UUID? = nil,
                productId: String? = nil,
                price: Double? = nil,
                quantity: Int? = nil) {
        
        self.name = name
        self.promotionId = promotionId
        self.productId = productId
        self.price = price
        self.quantity = quantity
    }
}

/**
 Product specific parameters for various events
 
 - parameter productId Product identifier
 - parameter price Optional product price
 - parameter quantity Optional quantity
 - parameter otherProductIds Optional set of productIds accompanying this particular product
 */
public struct ProductParams {
    var productId: String?
    var price: Double?
    var quantity: Int?
    var otherProductIds: [String]?
    
    public init(productId: String? = nil,
                price: Double? = nil,
                quantity: Int? = nil,
                otherProductIds: [String]? = nil
    ) {
        self.productId = productId
        self.price = price
        self.quantity = quantity
        self.otherProductIds = otherProductIds
    }
}

/**
 Type specific parameters for Page View events
 
 - parameter name: Event name
 - parameter promotionId: Promotion Id, if available
 - parameter productId: Unique identifier for a product
 - parameter price: Product price, if available
 - parameter quantity: Quantity, if available
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
 - parameter step: Optional identifier representing a step in the checkout process
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
 - parameter transactionId: Optional transaction identifier
 - parameter affiliation The store or affiliation from which this transaction occurred (e.g. Google Store), if available
 - parameter coupon Coupon, if available
 - parameter revenue The total associated with the transaction
 - parameter customProperties Optional set of general purpose custom properties, for example to help identifying certaion traits of the page
 */
public struct PurchaseParams {
    var products: [ProductParams]?
    var transactionId: String?
    var affiliation: String?
    var coupon: String?
    var revenue: Double?
    var customProperties: [String : String]?
    
    public init(products: [ProductParams]?,
                transactionId: String?,
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
 - parameter visitorId: This is a randomly generated id that identifies a visitor / user. It must be the same across the user session (or even longer when possible).
 - parameter currencyCode: Contains information about the valid currency. It must be uppercase, three-letter form of ISO 4217 currency codes. It is useful if there are more than one currency configured in the Crobox Container.
 - parameter localeCode: Locale code combination for the localization,
 - parameter userId: It is an identifier that allows coupling between Crobox user profiles with the client's user profiles, if available.
 - parameter timezone: Timezone
 - parameter customProperties: Free format custom properties to be forwarded to Crobox endpoints with each request, for example to help identifying certain traits of a visitor. Example: Map("mobileUser", "yes")
 */
public struct CroboxConfig {
    public let containerId: String
    public let visitorId: UUID
    public var currencyCode: CurrencyCode?
    public var localeCode: LocaleCode?
    public var userId: String?
    public var timezone: Int?
    public var customProperties: [String: String]?

    public init(containerId: String, visitorId: UUID, currencyCode: CurrencyCode? = nil, localeCode: LocaleCode? = nil, userId: String? = nil, timezone: Int? = nil, customProperties: [String: String]? = nil) {
        self.containerId = containerId
        self.visitorId = visitorId
        self.currencyCode = currencyCode
        self.localeCode = localeCode
        self.userId = userId
        self.timezone = timezone
        self.customProperties = customProperties
    }
}

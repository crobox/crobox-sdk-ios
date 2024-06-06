//
//  RequestQueryParams.swift
//  croboxSDK
//
//  Created by idris yıldız on 27.05.2024.
//

import Foundation

/*
 
 The list of query parameters that are applicable for mobile clients are below. These are applicable for both socket and promotions endpoints. Further details of each parameter are at the bottom. :
 
 User-Agent header for web
 Container ID
 Type: String
 Description: This is the unique id of the client's Crobox Container. It is generated and assigned by Crobox. So, this can be an alphanumeric constant configuration item, set only once by the sdk user.
 Example: cid="abc123"
 
 VisitorId
 Type: UUID
 Description: This is a randomly generated id that identifies a visitor / user. It must be the same across the user session (or even longer when possible). It must be in either plain UUIDv4 or Base64 string format. For simplicity, just pick Base64 for saving bandwidth space.
 UUID Example: vid=d4055206-fa5b-4eef-96c4-17e1c3a857fd
 Base64 Example: vid=1AVSBvpbTu-WxBfhw6hX_Q
 
 ViewId
 Type: UUID
 Description: This is a randomly generated id that identifies a unique page view. It is reused between various event and promotion requests while the user stays on the same page. Then, it is refreshed when a user goes to another page or reloads the same page. In other words, every socket or promotion request from the same view, should share the same ViewId. It must be in either plain UUID or Base64 string format. For simplicity, just pick Base64 for saving bandwidth space.
 UUID Example: vid=d4055206-fa5b-4eef-96c4-17e1c3a857fd
 Base64 Example: vid=1AVSBvpbTu-WxBfhw6hX_Q
 
 ViewCounter
 Type: Integer
 Description: Monotonically increasing counter, starting from 0. It is incremented per request in the same view. For instance, when the user is viewing and performing some actions on the same page, multiple promotion requests and events are sent. Among all these requests sharing the same ViewId, the counter should start from 0 and increment. This helps us group events by the view, and also guarantees for the uniqueness of a request/event when combined with ContainerId, VisitorId and ViewId.(Think of network failures or unintentional retries for example).
 Example: e=1
 
 OPTIONAL PARAMETERS
 
 LocaleCode
 Type: String
 Description: Locale code combination for the localization. It must be in {language}-{COUNTRY} format where
 
 the language must be lowercase, two-letter form of ISO 639-1 language codes
 the country must be uppercase, two-letter form of ISO 3166-1 Country codes
 Example: lc=en_US
 CurrencyCode
 Type: String
 Description: Contains information about the valid currency. It must be uppercase, three-letter form of ISO 4217 currency codes. It is useful when there are more than one currency configured in the Crobox Container.
 Example: cc=USD
 
 UserId
 Type: String
 Description: It is an identifier provided by the client that allows coupling of crobox user profiles with the client's user profiles, if available.
 Example: uid=abc123
 
 Timestamp
 Type: String
 Description: Timestamp as the millis since epoch, encoded with Base36.
 Example: ts=lu9znf91 (when timestamp is 1711554991093)
 
 Timezone
 Type: Integer
 Description: Current timezone of the user / device
 Example:tz=-4
 
 PageType
 Type: Integer
 Description: One of the values in predefined list of types of pages of the whole e-commerce funnel
 
 Custom Property [xyz]
 Type: String
 Description: Custom Property freely defined by the developer, using the prefix 'cp.'. This way, additional properties can be forwarded to Crobox endpoints, for example to help identifying certain traits of a visitor
 Example: cp.mobileUser=yes
 
 User-Agent header
 Description: This header is applicable for web clients but I wonder if it can be re-used for mobile clients as well, in order to distinguish between mobile devices / operating systems.
 */

//Mandatory
//"cid": ContainerId
//"e":  ViewCounter
//"vid": ViewId
//"pid": VisitorId


// Optional
//"cc":  CurrencyCode
//"lc" : LocaleCode
//"uid" : UserId
//"ts": Timestamp
//"tz": Timezone
//"pt" : PageType
//"cp.xyz" : Custom Property xyz

public struct RequestQueryParams {
    public var containerId: String   // ContainerId (mandatory)
    public var viewCounter: Int      // ViewCounter (mandatory)
    public var viewId: String        // ViewId (mandatory)
    public var visitorId: String     // VisitorId (mandatory)
    public var currencyCode: String? // CurrencyCode (optional)
    public var localeCode: LocaleCode? // LocaleCode (optional)
    public var userId: String?       // UserId (optional)
    public var timestamp: String?    // Timestamp (optional)
    public var timezone: Int?        // Timezone (optional)
    public var pageType: PageType?   // PageType (optional)
    public var customProperties: [String: String]? // Custom Properties (optional)
    public var pageUrl: String?      // ViewController Name
    public var referrerUrl: String?  // ViewController Name
    
    // Public initializer
    public init(containerId: String, viewCounter: Int, viewId: String, visitorId: String, currencyCode: String? = nil, localeCode: LocaleCode? = nil, userId: String? = nil, timestamp: String? = nil, timezone: Int? = nil, pageType: PageType? = nil, customProperties: [String: String]? = nil, pageUrl: String? = nil, referrerUrl: String? = nil) {
        self.containerId = containerId
        self.viewCounter = viewCounter
        self.viewId = viewId
        self.visitorId = visitorId
        self.currencyCode = currencyCode
        self.localeCode = localeCode
        self.userId = userId
        self.timestamp = timestamp
        self.timezone = timezone
        self.pageType = pageType
        self.customProperties = customProperties
        self.pageUrl = pageUrl
        self.referrerUrl = referrerUrl
    }
}

/*
 PageType
 
 Type: Integer
 Description: One of the values in predefined list of types of pages of the whole e-commerce funnel
 
 PageOther = 0
 PageIndex = 1
 PageOverview = 2
 PageDetail = 3
 PageCart = 4
 PageCheckout = 5
 PageComplete = 6
 PageSearch = 7
 Example: pt=0
 
 */

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

/*
 ∫
 Description: Specifies the type of the event. It must be one of following
 
 */

public enum EventType:String{
    case Click = "click" // Click
    case AddCart = "cart" // Add to Shopping Cart
    case RemoveCart = "rmcart" // Remove from Shopping Cart
    case PageView = "pageview" // PageView
    case Error = "error" // Error
    case CustomEvent = "event" // CustomEvent
}


/*
 
 The following arguments are applicable for error events( where t=error ). They are all optional.
 
 Tag
 Type: String
 Description: Free text for categorization of errors by the developer
 Example: tg=promotionAction
 
 Name
 Type: String
 Description: Free text for naming of errors by the developer
 Example: nm=TypeError
 
 Message
 Type: String
 Description: Free text for description of errors by the developer
 Example: msg=Cannot read product properties
 
 File
 Type: String
 Description: Free text for a file name, if specified
 Example: f=SomeFile.txt
 
 Line
 Type: Int
 Description: Simple numeric value to indicate the line number
 Example: l=2
 
 Device Pixel Ratio
 Type: Double
 Description: From https://stackoverflow.com/a/8785677
 
 The device pixel ratio is the ratio between physical pixels and logical pixels. For instance, the iPhone 4 and iPhone 4S report a device pixel ratio of 2, because the physical linear resolution is double the logical linear resolution.
 Physical resolution: 960 x 640
 Logical resolution: 480 x 320
 Example: dpr=2
 
 Device Language
 Type: String
 Description: Device language in the form of [language]-[country], with 2 lowercase letters each. Technically, it can be different than the lc locale, for instance lc=en-CA&ul=en-us can be a valid combination of a device from Canada
 Example: ul=en-us
 
 View Port size
 Type:String
 Description: From https://stackoverflow.com/a/73927240
 
 Your screen size is the number of pixels in the total width and height of your computer. The size of your viewport is the number of pixels in the browser window on your screen, so it is quite normal for the viewport to be smaller than the screen size.
 Example: vp=1173x686
 
 Screen Resolution Size
 Type: String
 Description: The whole screen size of the device
 Example: sr=1440x900
 
 */

//"tg" : Tag
//"nm" : Name
//"msg" : Message
//"f" : File
//"l" : Line
//"dpr" : Device Pixel Ratio
//"ul" : Device Language
//"vp" : View Port size
//"sr" : Screen Resolution Size

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

/*
 The following arguments are applicable for AddToCart events( where t=cart ). They are all optional
 
 ProductId
 Type: String
 Description: Identifier of a product.
 Example: pi=abcd-123
 
 Category
 Type: String
 Description: Category of a product.
 Example: cat=mens_shoes
 
 Price
 Type: Double
 Description: Numeric digits separated by comma or dot
 Example: price=123,456 or 123.456
 
 Quantity
 Type: Int
 Description: Numeric integer indicating the number of products
 Example: qty=2
 
 */

//"pi" : ProductId
//"cat" : Category
//"price" :  Price
//"qty": Quantity

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

public struct AddCartQueryParams {
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

public struct RemoveFromCartQueryParams {
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


/*
 
 The following arguments are applicable for click events( where t=event ). They are all optional
 
 Name
 Type: String
 Description: Custom event name
 Example: nm=banner-click
 
 Promotion ID
 Type: UUID
 Description: Promotion identifier
 Example: promoId=c97c02c0-1f5a-11ef-81c0-cd67b451d09e
 
 Product ID
 Type: String
 Description: Identifier of a product.
 Example: pi=abcd-123
 
 Category
 Type: String
 Description: Category of a product.
 Example: cat=mens_shoes
 
 Price
 Type: Double
 Description: Numeric digits separated by comma or dot
 Example: price=123,456 or 123.456
 
 Quantity
 Type: Int
 Description: Numeric integer indicating the number of products
 Example: qty=2
 
 */

//"nm" : Name
//"promoId" : Promotion ID
//"pi" : Product ID
//"cat" : Category
//"price" : Price
//"qty" : Quantity

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

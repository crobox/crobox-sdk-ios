@testable import Crobox
import XCTest

final class EventTests: XCTestCase {
    
    let overviewView = ViewContext(viewId: UUID(), viewType: .overview, customProperties: ["ios":"yes"])
    
    override class func setUp() {
        Crobox.shared.configure(CroboxConfig(containerId: "xlrc9t", visitorId: UUID.init(), localeCode: LocaleCode("en_US")))
        Crobox.shared.isLoggingEnabled = true
    }
    
    override func tearDown() async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    func testClickEvent() async throws {
        let clickParams = ClickParams(productId: "4")
        Crobox.shared.clickEvent(view: overviewView, params: clickParams)
    }
    
    func testAddCartEvent() async throws {
        let addToCartParams = CartParams(productId: "3", quantity: 12)
        Crobox.shared.addToCartEvent(view: overviewView, params: addToCartParams)
    }
    
    func testRmCartEvent() async throws {
        let removeFromCartParams = CartParams(productId: "3", quantity: 12)
        Crobox.shared.removeFromCartEvent(view: overviewView, params: removeFromCartParams)
    }
    
    func testErrorEvent() async throws {
        let errorParams = ErrorParams(tag: "ParsingError", name: "IllegalArgumentException", message: "bad input")
        Crobox.shared.errorEvent(view: overviewView, params: errorParams)
    }
    
    func testCustomEvent() async throws {
        let customParams = CustomEventParams(name: "custom-event", promotionId: UUID(), productId: "3", quantity: 1)
        Crobox.shared.customEvent(view: overviewView, params: customParams)
    }
    
    func testPageViewEvent() async throws {
        let viewParams = ViewParams(
            title: "some page title",
            product: ProductParams(productId: "1", list: "related products"),
            searchTerms: "some search terms",
            impressions: [
                ProductParams(productId: "5"),
                ProductParams(productId: "8")
            ],
            customProperties: ["event-specific": "value1", "event-specific2": "value2"]
        )
        Crobox.shared.viewEvent(view: overviewView, params: viewParams)
    }
    
    func testCheckoutEvent() async throws {
        let checkoutView = ViewContext(viewId: UUID(), viewType: .checkout, customProperties: ["checkout-specific":"yes"])
        
        let checkoutParams = CheckoutParams(
            products: [
                ProductParams(productId: "1"),
                ProductParams(productId: "2")
            ],
            step: "step-1",
            customProperties: ["page-specific-key":"value1"]
        )
        
        Crobox.shared.checkoutEvent(view: checkoutView, params: checkoutParams)
    }
    
    
    func testPurchaseEvent() async throws {
        let completeView = ViewContext(viewId: UUID(), viewType: .complete, customProperties: ["complete-specific":"yes"])
        
        let purchaseParams = PurchaseParams(
            products: [
                ProductParams(productId: "1", quantity: 1),
                ProductParams(productId: "2", quantity: 2)
            ],
            transactionId: "trx-id-1",
            affiliation: "some online store",
            coupon: "discount 1",
            revenue: 5.0,
            customProperties: ["event-specific": "value and value2"]
        )
        
        Crobox.shared.purchaseEvent(view: completeView, params: purchaseParams)
    }
    
    
    func testCounter_e() async throws {
        let errorParams = ErrorParams(tag: "ParsingError", name: "IllegalArgumentException", message: "bad input")
        Crobox.shared.errorEvent(view: overviewView, params: errorParams)
        let errorParams2 = ErrorParams(tag: "ParsingError2", name: "IllegalArgumentException2", message: "bad input2 ")
        Crobox.shared.errorEvent(view: overviewView, params: errorParams2)
    }
}

@testable import Crobox
import XCTest

final class EventTests: XCTestCase {
    
    let overviewPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageOverview, customProperties: ["ios":"yes"])
    
    override class func setUp() {
        Crobox.shared.initConfig(config: CroboxConfig(containerId: "xlrc9t", visitorId: UUID.init(), localeCode: .en_US))
        Crobox.shared.isDebug = true
    }
    
    override func tearDown() async throws {
        try await Task.sleep(for: .milliseconds(1000), tolerance: .seconds(0.5))
    }
    
    func testClickEvent() async throws {
        let clickQueryParams = ClickQueryParams(productId: "4")
        Crobox.shared.clickEvent(queryParams: overviewPageParams, clickQueryParams: clickQueryParams)
    }
    
    func testAddCartEvent() async throws {
        let addCartQueryParams = CartQueryParams(productId: "3", quantity: 12)
        Crobox.shared.addCartEvent(queryParams: overviewPageParams, addCartQueryParams:addCartQueryParams)
    }
    
    func testRmCartEvent() async throws {
        let rmCartQueryParams = CartQueryParams(productId: "3", quantity: 12)
        Crobox.shared.removeCartEvent(queryParams: overviewPageParams, rmCartQueryParams: rmCartQueryParams)
    }
    
    func testErrorEvent() async throws {
        let errorParams = ErrorQueryParams(tag: "ParsingError", name: "IllegalArgumentException", message: "bad input")
        Crobox.shared.errorEvent(queryParams: overviewPageParams, errorQueryParams: errorParams)
    }
    
    func testCustomEvent() async throws {
        let customParams = CustomQueryParams(name: "custom-event", promotionId: UUID(), productId: "3", quantity: 1)
        Crobox.shared.customEvent(queryParams: overviewPageParams, customQueryParams: customParams)
    }
    
    func testPageViewEvent() async throws {
        let pageViewParams = PageViewParams(
            pageTitle: "some page title",
            product: ProductParams(productId: "1", list: "related products"),
            searchTerms: "some search terms",
            impressions: [
                ProductParams(productId: "5"),
                ProductParams(productId: "8")
            ],
            customProperties: ["event-specific": "value1", "event-specific2": "value2"]
        )
        Crobox.shared.pageViewEvent(queryParams: overviewPageParams,
                                          pageViewParams: pageViewParams)
    }
    
    func testCheckoutEvent() async throws {
        let checkoutPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageCheckout, customProperties: ["checkout-specific":"yes"])
        
        let checkoutParams = CheckoutParams(
            products: [
                ProductParams(productId: "1"),
                ProductParams(productId: "2")
            ],
            step: "step-1",
            customProperties: ["page-specific-key":"value1"]
        )
        
        Crobox.shared.checkoutEvent(queryParams: checkoutPageParams, checkoutParams: checkoutParams)
    }
    
    
    func testPurchaseEvent() async throws {
        let pageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageComplete, customProperties: ["complete-specific":"yes"])
        
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
        
        Crobox.shared.purchaseEvent(queryParams: pageParams, purchaseParams: purchaseParams)
    }
    
    
    func testCounter_e() async throws {
        let errorParams = ErrorQueryParams(tag: "ParsingError", name: "IllegalArgumentException", message: "bad input")
        Crobox.shared.errorEvent(queryParams: overviewPageParams, errorQueryParams: errorParams)
        let errorParams2 = ErrorQueryParams(tag: "ParsingError2", name: "IllegalArgumentException2", message: "bad input2 ")
        Crobox.shared.errorEvent(queryParams: overviewPageParams, errorQueryParams: errorParams2)
    }
}

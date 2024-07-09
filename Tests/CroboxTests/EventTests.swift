@testable import Crobox
import XCTest

final class EventTests: XCTestCase {
    
    let overviewPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageOverview, customProperties: ["ios":"yes"])

    override class func setUp() {
        Crobox.shared.initConfig(config: CroboxConfig(containerId: "xlrc9t", visitorId: UUID.init(), localeCode: .en_US))
    }
    
    override func tearDown() async throws {
        try await Task.sleep(for: .milliseconds(100), tolerance: .seconds(0.5))
    }

    func testClickEvent() async throws {
        let clickQueryParams = ClickQueryParams(productId: "4")
        let _ = await Crobox.shared.clickEvent(queryParams: overviewPageParams, clickQueryParams: clickQueryParams)
    }
    
    func testAddCartEvent() async throws {
        let addCartQueryParams = CartQueryParams(productId: "3", price: 1.0, quantity: 12)
        let _ = await Crobox.shared.addCartEvent(queryParams: overviewPageParams, addCartQueryParams:addCartQueryParams)
    }
    
    func testRmCartEvent() async throws {
        let rmCartQueryParams = CartQueryParams(productId: "3", price: 1.0, quantity: 12)
        let _ = await Crobox.shared.removeCartEvent(queryParams: overviewPageParams, rmCartQueryParams: rmCartQueryParams)
    }
    
    func testErrorEvent() async throws {
        let errorParams = ErrorQueryParams(tag: "ParsingError", name: "IllegalArgumentException", message: "bad input")
        let _ = await Crobox.shared.errorEvent(queryParams: overviewPageParams, errorQueryParams: errorParams)
    }
    
    func testCustomEvent() async throws {
        let customParams = CustomQueryParams(name: "custom-event", promotionId: UUID(), productId: "3", price: 1.0, quantity: 1)
        let _ = await Crobox.shared.customEvent(queryParams: overviewPageParams, customQueryParams: customParams)
    }
    
}

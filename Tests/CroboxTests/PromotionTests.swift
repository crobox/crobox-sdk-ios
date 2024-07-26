@testable import Crobox
import XCTest

final class PromotionTests: XCTestCase {
    
    let overviewPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageOverview, customProperties: ["test":"async"])
    static var visitorId: UUID = UUID.init()
    
    override class func setUp() {
        Crobox.shared.initConfig(config: CroboxConfig(containerId: "xlrc9t", visitorId: visitorId, localeCode: .en_US))
        Crobox.shared.isDebug = true
    }
    
    override func tearDown() async throws {
        try await Task.sleep(for: .milliseconds(100), tolerance: .seconds(0.5))
    }
    
    func testPromotionsNoProduct() async throws {
        let checkoutPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageCheckout)
        let result = await Crobox.shared.promotions(placeholderId: "1", queryParams: checkoutPageParams)
        
        switch result {
        case let .success(response):
            XCTAssertNotNil(response.context.sessionId)
            XCTAssertEqual(PromotionTests.visitorId, response.context.visitorId)
            
        case .failure(_):
            XCTFail()
        }
    }
    
    func testPromotionsOneProduct() async throws {
        let detailPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageDetail)
        let result = await Crobox.shared.promotions(placeholderId: "1",
                                                    queryParams: detailPageParams,
                                                    productIds: ["29883481"])
        switch result {
        case let .success(response):
            XCTAssertNotNil(response.context.sessionId)
            XCTAssertEqual(PromotionTests.visitorId, response.context.visitorId)
        case .failure(_):
            XCTFail()
        }
        
        func testPromotionsMultiProducts() async throws {
            let result = await Crobox.shared.promotions(placeholderId: "1",
                                                        queryParams: overviewPageParams,
                                                        productIds: ["product1", "product2", "product3", "product4"])
            switch result {
            case let .success(response):
                let context = response.context
                XCTAssertNotNil(context.sessionId)
                XCTAssertEqual(PromotionTests.visitorId, context.visitorId)
            case .failure(_):
                XCTFail()
            }
            
        }
    }
    
}

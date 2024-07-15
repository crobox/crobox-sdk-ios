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
        let expectation = XCTestExpectation(description: "receive successful response")
        
        let checkoutPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageCheckout)
        let _ = await Crobox.shared.promotions(placeholderId: "1", queryParams: checkoutPageParams) { result in
            switch result {
            case let .success(response):
                XCTAssertNotNil(response.context.sessionId)
                XCTAssertEqual(PromotionTests.visitorId, response.context.visitorId)
                expectation.fulfill()
            case let .failure(error):
                print(error)
            }
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    func testPromotionsOneProduct() async throws {
        let expectation = XCTestExpectation(description: "receive successful response")
        
        let detailPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageDetail)
        let _ = await Crobox.shared.promotions(placeholderId: "1",
                                               queryParams: detailPageParams,
                                               productIds: ["29883481"]) { result in
            switch result {
            case let .success(response):
                XCTAssertNotNil(response.context.sessionId)
                XCTAssertEqual(PromotionTests.visitorId, response.context.visitorId)
                expectation.fulfill()
            case let .failure(error):
                print(error)
            }
        }
        await fulfillment(of: [expectation], timeout: 1.0)
        
    }
    
    func testPromotionsMultiProducts() async throws {
        let expectation = XCTestExpectation(description: "receive successful response")
        
        let _ = await Crobox.shared.promotions(placeholderId: "1",
                                               queryParams: overviewPageParams,
                                               productIds: ["product1", "product2", "product3", "product4"]) { result in
            switch result {
            case let .success(response):
                let context = response.context
                XCTAssertNotNil(context.sessionId)
                XCTAssertEqual(PromotionTests.visitorId, context.visitorId)
                expectation.fulfill()
            
            case let .failure(error):
                print(error)
            }
        }
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
}


@testable import Crobox
import XCTest

final class PromotionFailureTests: XCTestCase {
    
    func testPromotionsError() async throws {
        let overviewPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageOverview, customProperties: ["test":"async"])
        let brokenConfig = CroboxConfig(containerId: "9999", visitorId: UUID.init(), localeCode: .en_US)
        Crobox.shared.initConfig(config: brokenConfig)
        Crobox.shared.isDebug = true
        
        let expectation = XCTestExpectation(description: "receive error response")
        let _ = await Crobox.shared.promotions(placeholderId: "30",
                                               queryParams: overviewPageParams,
                                               productIds: ["29883481", "04133050", "3A626400"]) { result in
            switch result {
            case let .success(p):
                XCTFail("\(p)")
            case let .failure(error):
                XCTFail("failure: \(error)")
                switch error {
                case CroboxErrors.httpError(let statusCode, let cause):
                    XCTAssertEqual(405, statusCode)
                    expectation.fulfill()
                default :
                    XCTFail("other failure: \(error)")
                }
            }
        }
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
}


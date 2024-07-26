@testable import Crobox
import XCTest

final class PromotionFailureTests: XCTestCase {
    
    func testPromotionsError() async throws {
        let overviewPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageOverview, customProperties: ["test":"async"])
        let brokenConfig = CroboxConfig(containerId: "9999", visitorId: UUID.init(), localeCode: .en_US)
        Crobox.shared.initConfig(config: brokenConfig)
        Crobox.shared.isDebug = true
        
        let result = await Crobox.shared.promotions(placeholderId: "30",
                                                    queryParams: overviewPageParams,
                                                    productIds: ["29883481", "04133050", "3A626400"])
        switch result {
        case .success(_):
            XCTFail("\(result)")
        case let .failure(error):
            switch error {
            case CroboxErrors.httpError(let statusCode, _):
                XCTAssertEqual(405, statusCode)
            default :
                XCTFail("other failure: \(error)")
            }
        }
    }
    
}


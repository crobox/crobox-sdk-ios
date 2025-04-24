@testable import Crobox
import XCTest

final class PromotionFailureTests: XCTestCase {
    
    override func tearDown() async throws {
        try await Task.sleep(for: .milliseconds(2000), tolerance: .seconds(0.5))
    }
    
    func testPromotionsError() async throws {
        let overviewPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageOverview, customProperties: ["test":"failure"])
        let brokenConfig = CroboxConfig(containerId: "9999", visitorId: UUID.init(), localeCode: .en_US)
        Crobox.shared.initConfig(config: brokenConfig)
        Crobox.shared.isDebug = true
        
        let result = await Crobox.shared.promotions(placeholderId: "1",
                                                    queryParams: overviewPageParams,
                                                    productIds: ["1", "2", "3"])
        switch result {
        case .success(_):
            XCTFail("\(result)")
        case let .failure(error):
            switch error {
            case CroboxErrors.httpError(let statusCode):
                XCTAssertEqual(405, statusCode)
            default :
                XCTFail("other failure: \(error)")
            }
        }
    }
    
}


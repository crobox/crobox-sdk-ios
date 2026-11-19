@testable import Crobox
import XCTest

final class PromotionFailureTests: XCTestCase {
    
    override func tearDown() async throws {
        try await Task.sleep(for: .milliseconds(2000), tolerance: .seconds(0.5))
    }
    
    func testPromotionsError() async throws {
        let overviewView = ViewContext(viewId: UUID(), viewType: .overview, customProperties: ["test":"failure"])
        let brokenConfig = CroboxConfig(containerId: "9999", visitorId: UUID.init(), localeCode: LocaleCode("en_US"))
        Crobox.shared.configure(brokenConfig)
        Crobox.shared.isLoggingEnabled = true
        
        let result = await Crobox.shared.promotions(placementId: 1,
                                                    view: overviewView,
                                                    productIds: ["1", "2", "3"])
        switch result {
        case .success(_):
            XCTFail("\(result)")
        case let .failure(error):
            switch error {
            case CroboxError.httpError(let statusCode):
                XCTAssertEqual(405, statusCode)
            default :
                XCTFail("other failure: \(error)")
            }
        }
    }
    
}


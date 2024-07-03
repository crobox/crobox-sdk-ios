@testable import Crobox
import XCTest

final class ConstantTests: XCTestCase {

    func testExample() throws {
        let uuid = UUID.init()
        XCTAssertEqual(uuid, RequestQueryParams(viewId: uuid, pageType: PageType.PageCart).viewId)
    }
    
}

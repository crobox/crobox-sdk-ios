@testable import Crobox
import XCTest

final class LocaleCodeTests: XCTestCase {

    func testFromLocale() {
        XCTAssertEqual("en_US", LocaleCode.of(Locale(identifier: "en_US")).code)
        XCTAssertEqual("nl_BE", LocaleCode.of(Locale(identifier: "nl_BE")).code)
        XCTAssertEqual("fr", LocaleCode.of(Locale(identifier: "fr")).code)
        XCTAssertEqual("zh_CN", LocaleCode.of(Locale(identifier: "zh-Hans_CN")).code)
    }

    func testComparesByCode() {
        XCTAssertEqual(LocaleCode("en_US"), LocaleCode.of(Locale(identifier: "en_US")))
        let literal: LocaleCode = "en_US"
        XCTAssertEqual(LocaleCode("en_US"), literal)
    }

    func testIsSentAsLc() {
        Crobox.shared.initConfig(config: CroboxConfig(containerId: "xlrc9t", visitorId: UUID(), localeCode: LocaleCode("nl_BE")))
        let params = CroboxAPIServices.shared.eventParameters(eventType: .Click, additionalParams: nil,
                                                              queryParams: RequestQueryParams(viewId: UUID(), pageType: .PageIndex))
        XCTAssertEqual("nl_BE", params["lc"])
    }
}

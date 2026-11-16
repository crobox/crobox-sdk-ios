@testable import Crobox
import XCTest

final class UserAgentTests: XCTestCase {

    func testAppendsTheSdkVersionToTheDefaultUserAgent() {
        let ua = UserAgent.build(appName: "MyShop", appVersion: "42", cfNetworkVersion: "1490.0.4", darwinVersion: "23.2.0")
        XCTAssertEqual(ua, "MyShop/42 CFNetwork/1490.0.4 Darwin/23.2.0 CroboxSDK/\(Version.current)")
    }

    func testEscapesTheAppNameLikeTheDefaultUserAgent() {
        let ua = UserAgent.build(appName: "Mÿ Shop/2", appVersion: "1", cfNetworkVersion: "1490.0.4", darwinVersion: "23.2.0")
        XCTAssertEqual(ua, "M%C3%BF%20Shop%2F2/1 CFNetwork/1490.0.4 Darwin/23.2.0 CroboxSDK/\(Version.current)")
    }

    func testLeavesOutWhatIsUnknown() {
        XCTAssertEqual(UserAgent.build(appName: "MyShop", appVersion: nil, cfNetworkVersion: nil, darwinVersion: "23.2.0"),
                       "MyShop CroboxSDK/\(Version.current)")
        XCTAssertEqual(UserAgent.build(appName: nil, appVersion: nil, cfNetworkVersion: nil, darwinVersion: nil),
                       "CroboxSDK/\(Version.current)")
    }

    func testReplacesCharactersThatAreNotPrintableAscii() {
        XCTAssertEqual(UserAgent.sanitize("Galaxy™ S\n"), "Galaxy_ S_")
    }

    func testValueEndsWithTheSdkVersion() {
        XCTAssertTrue(UserAgent.value.hasSuffix(" CroboxSDK/\(Version.current)") || UserAgent.value == "CroboxSDK/\(Version.current)",
                      UserAgent.value)
    }
}

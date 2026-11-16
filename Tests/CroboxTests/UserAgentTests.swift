@testable import Crobox
import XCTest

final class UserAgentTests: XCTestCase {

    func testAppendsTheSdkVersionToTheDefaultUserAgent() {
        let ua = UserAgent.build(appName: "MyShop", appVersion: "42", cfNetworkVersion: "1490.0.4", darwinVersion: "23.2.0")
        XCTAssertEqual(ua, "MyShop/42 CFNetwork/1490.0.4 Darwin/23.2.0 CroboxSDK/\(UserAgent.sdkVersion)")
    }

    func testEscapesTheAppNameLikeTheDefaultUserAgent() {
        let ua = UserAgent.build(appName: "Mÿ Shop/2", appVersion: "1", cfNetworkVersion: "1490.0.4", darwinVersion: "23.2.0")
        XCTAssertEqual(ua, "M%C3%BF%20Shop%2F2/1 CFNetwork/1490.0.4 Darwin/23.2.0 CroboxSDK/\(UserAgent.sdkVersion)")
    }

    func testLeavesOutWhatIsUnknown() {
        XCTAssertEqual(UserAgent.build(appName: "MyShop", appVersion: nil, cfNetworkVersion: nil, darwinVersion: "23.2.0"),
                       "MyShop CroboxSDK/\(UserAgent.sdkVersion)")
        XCTAssertEqual(UserAgent.build(appName: nil, appVersion: nil, cfNetworkVersion: nil, darwinVersion: nil),
                       "CroboxSDK/\(UserAgent.sdkVersion)")
    }

    func testReplacesCharactersThatAreNotPrintableAscii() {
        XCTAssertEqual(UserAgent.sanitize("Galaxy™ S\n"), "Galaxy_ S_")
    }

    func testValueEndsWithTheSdkVersion() {
        XCTAssertTrue(UserAgent.value.hasSuffix(" CroboxSDK/\(UserAgent.sdkVersion)") || UserAgent.value == "CroboxSDK/\(UserAgent.sdkVersion)",
                      UserAgent.value)
    }

    func testSdkVersionMatchesThePodspec() throws {
        let podspec = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("croboxSDK.podspec")
        let contents = try String(contentsOf: podspec, encoding: .utf8)
        let line = try XCTUnwrap(contents.split(separator: "\n").first { $0.trimmingCharacters(in: .whitespaces).hasPrefix("spec.version") })
        XCTAssertEqual(line.split(separator: "\"").dropFirst().first.map(String.init), UserAgent.sdkVersion,
                       "Update UserAgent.sdkVersion when releasing a new version")
    }
}

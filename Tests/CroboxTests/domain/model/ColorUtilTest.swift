@testable import Crobox
import XCTest

final class ColorUtilTests: XCTestCase {

    func testParseHexColor() {
        func rgba(_ s: String) -> [UInt8]? {
            parseHexColor(s).map { [$0.red, $0.green, $0.blue, $0.alpha] }
        }
        XCTAssertEqual([0x11, 0x22, 0x33, 0xFF], rgba("#123"))
        XCTAssertEqual([0x11, 0x22, 0x33, 0x44], rgba("#1234"))
        XCTAssertEqual([0xAB, 0xCD, 0xEF, 0xFF], rgba("#abcdef"))
        XCTAssertEqual([0xFF, 0x00, 0x00, 0x80], rgba("#FF000080"))
        XCTAssertEqual([0xFF, 0xFF, 0xFF, 0xFF], rgba(" #fff "))

        for invalid in ["", "#", "fff", "#12", "#12345", "#1234567", "#123456789", "#zzzzzz", "#12345g", "#+fffff", "rgba(0,0,0,1)"] {
            XCTAssertNil(parseHexColor(invalid), invalid)
        }
    }

    #if canImport(UIKit)
    func testHexToUIColor() async throws {
        let white = "#ffffff"
        XCTAssertEqual(true, white.toUIColor()?.isWhite)
        XCTAssertEqual(white.uppercased(), white.toUIColor()?.hex())
        
        let black = "#000000"
        XCTAssertEqual(true, black.toUIColor()?.isBlack)
        
        let red = "#ff0000"
        XCTAssertEqual(UIColor.red, red.toUIColor())
        
        let green = "#00ff00"
        XCTAssertEqual(UIColor.green, green.toUIColor())
        
        let blue = "#0000ff"
        XCTAssertEqual(UIColor.blue, blue.toUIColor())
        
        let err = "abc"
        XCTAssertNil(err.toUIColor())

        let malformed = "#aaaaa"
        XCTAssertNil(malformed.toUIColor())
    }
    
    func testShortHexToUIColor() async throws {
        XCTAssertEqual(UIColor.red, "#f00".toUIColor())
        XCTAssertEqual(UIColor.blue.alpha(0.0), "#00f0".toUIColor())
    }

    func testHexWithAlphaIsRRGGBBAA() async throws {
        XCTAssertEqual(UIColor.red.alpha(0.0), "#ff000000".toUIColor())
        XCTAssertEqual(UIColor.blue, "#0000ffff".toUIColor())
    }

    func testRGBAToUIColor() async throws {
        
        let white = "rgba(255, 255, 255, 1)"
        XCTAssertEqual(true, white.toUIColor()?.isWhite)
        
        let black = "rgba(0, 0, 0, 1)"
        XCTAssertEqual(true, black.toUIColor()?.isBlack)

        let red = "rgba(255, 0, 0, 1)"
        XCTAssertEqual(UIColor.red, red.toUIColor())
        
        let green = "rgba(0, 255, 0, 1)"
        XCTAssertEqual(UIColor.green, green.toUIColor())
        
        let blue = "rgba(0, 0, 255, 1)"
        XCTAssertEqual(UIColor.blue, blue.toUIColor())
        
        let malformed = "rgba(0, 0, 1)"
        XCTAssertNil(malformed.toUIColor())
    }
    
    func testRGBATransparentToUIColor() async throws {
        let alpha = 0.5
        let white = "rgba(255, 255, 255, \(alpha))"
        XCTAssertEqual(true, white.toUIColor()?.isWhite)
        
        let black = "rgba(0, 0, 0, \(alpha))"
        XCTAssertEqual(true, black.toUIColor()?.isBlack)

        let red = "rgba(255, 0, 0, \(alpha))"
        XCTAssertEqual(UIColor.red.alpha(alpha), red.toUIColor())
        
        let green = "rgba(0, 255, 0, \(alpha))"
        XCTAssertEqual(UIColor.green.alpha(alpha), green.toUIColor())
        
        let blue = "rgba(0, 0, 255, \(alpha))"
        XCTAssertEqual(UIColor.blue.alpha(alpha), blue.toUIColor())
    }

    #endif
}


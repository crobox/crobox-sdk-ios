@testable import Crobox
import XCTest

final class ColorUtilTests: XCTestCase {

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
        let white = "rgba(255, 255, 255, \(alpha)"
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


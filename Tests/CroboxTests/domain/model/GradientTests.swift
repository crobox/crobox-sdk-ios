@testable import Crobox
import XCTest

final class GradientTests: XCTestCase {

    private func stop(_ hex: String, _ location: CGFloat) -> GradientStop {
        let color = parseHexColor(hex)!
        return GradientStop(red: CGFloat(color.red) / 255,
                            green: CGFloat(color.green) / 255,
                            blue: CGFloat(color.blue) / 255,
                            alpha: CGFloat(color.alpha) / 255,
                            location: location)
    }

    func testParsesTheAppsLinearGradient() {
        XCTAssertEqual(
            .linear(angle: 90, stops: [stop("#22d8ef", 0), stop("#f4174d", 0.7), stop("#f7460d", 1)]),
            parseGradient("linear-gradient(90deg, #22d8ef 0%, #f4174d 70%, #f7460d 100%)")
        )
    }

    func testParsesTheAppsRadialGradient() {
        XCTAssertEqual(
            .radial(stops: [stop("#ffffff", 0), stop("#000000", 1)]),
            parseGradient("radial-gradient(circle, #ffffff 0%, #000000 100%)")
        )
    }

    func testParsesTransparentStops() {
        XCTAssertEqual(
            .linear(angle: 45, stops: [
                GradientStop(red: 1, green: 0, blue: 0, alpha: 0.5, location: 0.1),
                stop("#0000ff", 0.9)
            ]),
            parseGradient("linear-gradient(45deg, rgba(255, 0, 0, 0.5) 10%, #0000ff 90%)")
        )
    }

    func testFillsInMissingLocationsAsCssDoes() throws {
        let gradient = try XCTUnwrap(parseGradient("linear-gradient(#ff0000, #00ff00, #0000ff 60%, #ffffff, #000000)"))
        guard case .linear(let angle, let stops) = gradient else {
            return XCTFail("expected a linear gradient")
        }
        XCTAssertEqual(180, angle)
        for (expected, stop) in zip([0, 0.3, 0.6, 0.8, 1] as [CGFloat], stops) {
            XCTAssertEqual(expected, stop.location, accuracy: 0.0001)
        }
    }

    func testMovesAStopBeforeAnEarlierOneUpToIt() {
        XCTAssertEqual([0.5, 0.5], parseGradient("linear-gradient(90deg, #ff0000 50%, #0000ff 20%)")?.stops.map(\.location))
    }

    func testIsNilForAPlainColorOrSomethingElse() {
        for value in [
            "",
            "#ff0000",
            "rgba(255, 0, 0, 0.5)",
            "linear-gradient(90deg, #ff0000 0%)",
            "linear-gradient(90deg, nonsense 0%, #ff0000 100%)",
            "linear-gradient(to right, #ff0000 0%, #0000ff 100%)",
            "linear-gradient(90deg, rgba(255, 0, 0) 0%, #0000ff 100%)",
            "radial-gradient(ellipse, #ff0000 0%, #0000ff 100%)",
            "conic-gradient(#ff0000, #0000ff)"
        ] {
            XCTAssertNil(parseGradient(value), value)
        }
    }

    func testRunsTheLineFromEdgeToEdgeForTheSides() {
        assertPoints(linearGradientLine(angle: 90, width: 200, height: 100), (0, 50), (200, 50))
        assertPoints(linearGradientLine(angle: 180, width: 200, height: 100), (100, 0), (100, 100))
        assertPoints(linearGradientLine(angle: 0, width: 200, height: 100), (100, 100), (100, 0))
    }

    func testRunsTheLineThroughTheCornersPerpendicularToIt() {
        // At 45deg on a square, the line runs corner to corner
        assertPoints(linearGradientLine(angle: 45, width: 100, height: 100), (0, 100), (100, 0))
    }

    func testParsesABackgroundThatIsAGradientOrAPlainColor() {
        XCTAssertEqual(.linear(angle: 180, stops: [stop("#ff0000", 0), stop("#ff0000", 1)]), parseBackground("#ff0000"))
        XCTAssertEqual(.linear(angle: 90, stops: [stop("#ff0000", 0), stop("#0000ff", 1)]),
                       parseBackground("linear-gradient(90deg, #ff0000 0%, #0000ff 100%)"))
        XCTAssertNil(parseBackground(""))
        XCTAssertNil(parseBackground("nonsense"))
    }

    #if canImport(QuartzCore)
    func testTextBadgeHasABackgroundLayerForAGradientOrAColor() throws {
        func badge(_ background: String?) -> TextBadge {
            TextBadge(text: "Sale", fontColorValue: nil, backgroundValue: background, borderColorValue: nil)
        }
        let layer = try XCTUnwrap(badge("linear-gradient(90deg, #ff0000 0%, #0000ff 100%)").backgroundLayer())
        XCTAssertTrue(layer.needsDisplayOnBoundsChange)
        XCTAssertNotNil(badge("#ff0000").backgroundLayer())
        XCTAssertNil(badge(nil).backgroundLayer())
        XCTAssertNil(badge("nonsense").backgroundLayer())
    }
    #endif

    private func assertPoints(_ points: (start: CGPoint, end: CGPoint),
                              _ start: (CGFloat, CGFloat),
                              _ end: (CGFloat, CGFloat),
                              file: StaticString = #filePath,
                              line: UInt = #line) {
        XCTAssertEqual(start.0, points.start.x, accuracy: 0.001, "start x", file: file, line: line)
        XCTAssertEqual(start.1, points.start.y, accuracy: 0.001, "start y", file: file, line: line)
        XCTAssertEqual(end.0, points.end.x, accuracy: 0.001, "end x", file: file, line: line)
        XCTAssertEqual(end.1, points.end.y, accuracy: 0.001, "end y", file: file, line: line)
    }
}

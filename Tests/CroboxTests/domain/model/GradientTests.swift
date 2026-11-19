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
        assertPoints(linearGradientPoints(angle: 90, width: 200, height: 100), (0, 0.5), (1, 0.5))
        assertPoints(linearGradientPoints(angle: 180, width: 200, height: 100), (0.5, 0), (0.5, 1))
        assertPoints(linearGradientPoints(angle: 0, width: 200, height: 100), (0.5, 1), (0.5, 0))
    }

    func testRunsTheLineThroughTheCornersPerpendicularToIt() {
        // At 45deg on a square, the line runs corner to corner
        assertPoints(linearGradientPoints(angle: 45, width: 100, height: 100), (0, 1), (1, 0))
    }

    func testTextBadgeHasAGradientOrAColor() {
        let gradient = TextBadge(text: "Sale", fontColor: nil,
                                 backgroundColor: "linear-gradient(90deg, #ff0000 0%, #0000ff 100%)",
                                 borderColor: nil, name: "MobAppTextBadgeTsx")
        XCTAssertNotNil(gradient.backgroundGradient())

        let solid = TextBadge(text: "Sale", fontColor: nil, backgroundColor: "#ff0000", borderColor: nil,
                              name: "MobAppTextBadgeTsx")
        XCTAssertNil(solid.backgroundGradient())
    }

    #if canImport(QuartzCore)
    func testLinearLayerFollowsItsBounds() throws {
        let gradient = try XCTUnwrap(parseGradient("linear-gradient(90deg, #ff0000 0%, #0000ff 100%)"))
        let layer = gradient.makeLayer()
        XCTAssertEqual(.axial, layer.type)
        XCTAssertEqual(2, layer.colors?.count)
        XCTAssertEqual([0, 1], layer.locations)

        layer.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        layer.layoutIfNeeded()
        assertPoints((layer.startPoint, layer.endPoint), (0, 0.5), (1, 0.5))

        // At 45deg the line depends on the box: corner to corner on a square, not on a wide badge
        let diagonal = try XCTUnwrap(parseGradient("linear-gradient(45deg, #ff0000 0%, #0000ff 100%)")).makeLayer()
        diagonal.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        diagonal.layoutIfNeeded()
        assertPoints((diagonal.startPoint, diagonal.endPoint), (0, 1), (1, 0))
    }

    func testRadialLayerReachesTheFarthestCorner() throws {
        let gradient = try XCTUnwrap(parseGradient("radial-gradient(circle, #ff0000 0%, #0000ff 100%)"))
        let layer = gradient.makeLayer()
        XCTAssertEqual(.radial, layer.type)

        layer.frame = CGRect(x: 0, y: 0, width: 80, height: 60)
        layer.layoutIfNeeded()
        // The radius is 50, half the diagonal, which is 50/80 of the width and 50/60 of the height
        assertPoints((layer.startPoint, layer.endPoint), (0.5, 0.5), (0.5 + 50.0 / 80, 0.5 + 50.0 / 60))
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

#if canImport(QuartzCore)
@testable import Crobox
import QuartzCore
import XCTest

/// Draws each badge's background, a plain color or a gradient, as its layer does, and compares pixels with what Chromium draws for the
/// same CSS, which is what the App's preview shows. The expected colors were read from Chromium's screenshots of these cases, and the Android SDK checks
/// the same ones.
final class GradientRenderingTests: XCTestCase {

    private struct Sample {
        let x: Int
        let y: Int
        let color: String
    }

    private struct Case {
        let css: String
        let width: Int
        let height: Int
        let samples: [Sample]
    }

    /// Per color channel, out of 255: room for rounding and dithering, and too little to see
    private let tolerance = 3

    func testDrawsWhatTheBrowserDraws() throws {
        var failures: [String] = []
        for gradientCase in cases {
            let badge = TextBadge(text: "Sale", fontColorValue: nil, backgroundValue: gradientCase.css,
                                  borderColorValue: nil)
            let layer = try XCTUnwrap(badge.backgroundLayer())
            layer.frame = CGRect(x: 0, y: 0, width: gradientCase.width, height: gradientCase.height)
            let pixels = try render(layer, width: gradientCase.width, height: gradientCase.height)
            for sample in gradientCase.samples {
                let offset = (sample.y * gradientCase.width + sample.x) * 4
                let actual = Array(pixels[offset..<offset + 4])
                let color = try XCTUnwrap(parseHexColor(sample.color))
                let expected = [color.red, color.green, color.blue, color.alpha]
                let difference = zip(actual, expected).map { abs(Int($0) - Int($1)) }.max() ?? 0
                if difference > tolerance {
                    let got = actual.map { String(format: "%02x", $0) }.joined()
                    failures.append("\(gradientCase.css) at (\(sample.x), \(sample.y)): expected \(sample.color), got #\(got)")
                }
            }
        }
        XCTAssertTrue(failures.isEmpty, failures.joined(separator: "\n"))
    }

    /// Draws the layer's contents into an sRGB bitmap, flipped so that y runs down from the top as in a layer on iOS,
    /// and returns its RGBA bytes
    private func render(_ layer: CALayer, width: Int, height: Int) throws -> [UInt8] {
        let space = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let context = try XCTUnwrap(CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
                                              bytesPerRow: width * 4, space: space,
                                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1, y: -1)
        layer.draw(in: context)
        let data = try XCTUnwrap(context.data)
        return Array(UnsafeBufferPointer(start: data.assumingMemoryBound(to: UInt8.self), count: width * height * 4))
    }

    private let cases: [Case] = [
        Case(css: "#ff6396",
             width: 100, height: 40,
             samples: [
                       Sample(x: 10, y: 4, color: "#ff6396"),
                       Sample(x: 50, y: 20, color: "#ff6396"),
                       Sample(x: 90, y: 36, color: "#ff6396")
             ]),
        Case(css: "linear-gradient(87deg, #24d9f3 0%, #f40472 62%, #f74703 100%)",
             width: 200, height: 100,
             samples: [
                       Sample(x: 20, y: 10, color: "#4dafd9"),
                       Sample(x: 100, y: 10, color: "#d02988"),
                       Sample(x: 180, y: 10, color: "#f6351f"),
                       Sample(x: 20, y: 50, color: "#49b2db"),
                       Sample(x: 100, y: 50, color: "#cc2c8a"),
                       Sample(x: 180, y: 50, color: "#f63422"),
                       Sample(x: 20, y: 90, color: "#46b6dd"),
                       Sample(x: 100, y: 90, color: "#c9308c"),
                       Sample(x: 180, y: 90, color: "#f63225")
             ]),
        Case(css: "linear-gradient(45deg, #ff0000 0%, #0000ff 100%)",
             width: 200, height: 60,
             samples: [
                       Sample(x: 20, y: 6, color: "#b60048"),
                       Sample(x: 100, y: 6, color: "#680097"),
                       Sample(x: 180, y: 6, color: "#1900e5"),
                       Sample(x: 20, y: 30, color: "#ce0031"),
                       Sample(x: 100, y: 30, color: "#7f007f"),
                       Sample(x: 180, y: 30, color: "#3100ce"),
                       Sample(x: 20, y: 54, color: "#e50019"),
                       Sample(x: 100, y: 54, color: "#970068"),
                       Sample(x: 180, y: 54, color: "#4800b6")
             ]),
        Case(css: "linear-gradient(#ff0000, #00ff00, #0000ff 60%, #ffffff, #000000)",
             width: 120, height: 100,
             samples: [
                       Sample(x: 12, y: 10, color: "#a55900"),
                       Sample(x: 60, y: 10, color: "#a55900"),
                       Sample(x: 108, y: 10, color: "#a55900"),
                       Sample(x: 12, y: 50, color: "#0050ae"),
                       Sample(x: 60, y: 50, color: "#0050ae"),
                       Sample(x: 108, y: 50, color: "#0050ae"),
                       Sample(x: 12, y: 90, color: "#797979"),
                       Sample(x: 60, y: 90, color: "#797979"),
                       Sample(x: 108, y: 90, color: "#797979")
             ]),
        Case(css: "linear-gradient(135deg, #22d8ef 0%, #ff6396 50%, #fafe00 100%)",
             width: 150, height: 60,
             samples: [
                       Sample(x: 15, y: 6, color: "#51c0dd"),
                       Sample(x: 75, y: 6, color: "#cf7daa"),
                       Sample(x: 135, y: 6, color: "#fe9a61"),
                       Sample(x: 15, y: 30, color: "#83a5c8"),
                       Sample(x: 75, y: 30, color: "#ff6595"),
                       Sample(x: 135, y: 30, color: "#fcbd3f"),
                       Sample(x: 15, y: 54, color: "#b68ab4"),
                       Sample(x: 75, y: 54, color: "#fe8873"),
                       Sample(x: 135, y: 54, color: "#fbe11d")
             ]),
        Case(css: "radial-gradient(circle, #ffffff 0%, #000000 100%)",
             width: 200, height: 100,
             samples: [
                       Sample(x: 20, y: 10, color: "#343434"),
                       Sample(x: 100, y: 10, color: "#a5a5a5"),
                       Sample(x: 180, y: 10, color: "#323232"),
                       Sample(x: 20, y: 50, color: "#494949"),
                       Sample(x: 100, y: 50, color: "#fdfdfd"),
                       Sample(x: 180, y: 50, color: "#474747"),
                       Sample(x: 20, y: 90, color: "#333333"),
                       Sample(x: 100, y: 90, color: "#a2a2a2"),
                       Sample(x: 180, y: 90, color: "#313131")
             ])
    ]
}
#endif

@testable import Crobox
import XCTest

/// Offline tests for how requests are built
final class RequestParametersTests: XCTestCase {

    override func setUp() {
        Crobox.shared.initConfig(config: CroboxConfig(containerId: "xlrc9t",
                                                      visitorId: UUID(),
                                                      customProperties: ["app": "ios", "shared": "config"]))
    }

    private func parameters(_ eventType: EventType, _ params: Any?, pageType: PageType = .PageOverview,
                            customProperties: [String: String]? = nil) -> [String: String] {
        let queryParams = RequestQueryParams(viewId: UUID(), pageType: pageType, customProperties: customProperties)
        return CroboxAPIServices.shared.eventParameters(eventType: eventType, additionalParams: params, queryParams: queryParams)
    }

    func testPageViewImpressionsUseImpPrefix() {
        let params = parameters(.PageView, PageViewParams(pageTitle: nil, product: nil, searchTerms: nil,
                                                          impressions: (0..<12).map { ProductParams(productId: "p\($0)") },
                                                          customProperties: nil))
        XCTAssertEqual("p0", params["imp[0]"])
        XCTAssertEqual("p11", params["imp[11]"])
        XCTAssertNil(params["[0]"])
    }

    func testCheckoutSendsProductsAndCheckoutPageType() {
        let params = parameters(.Checkout, CheckoutParams(products: [ProductParams(productId: "1"), ProductParams(productId: "2")],
                                                          step: "1", customProperties: nil),
                                pageType: .PageOther)
        XCTAssertEqual("pageview", params["t"])
        XCTAssertEqual("5", params["pt"])
        XCTAssertEqual("1", params["imp[0]"])
        XCTAssertEqual("2", params["imp[1]"])
    }

    func testPurchaseSendsProductsAndCompletePageType() {
        let params = parameters(.Purchase, PurchaseParams(products: [ProductParams(productId: "1")], transactionId: "t1",
                                                          affiliation: nil, coupon: nil, revenue: 1.0, customProperties: nil),
                                pageType: .PageOther)
        XCTAssertEqual("pageview", params["t"])
        XCTAssertEqual("6", params["pt"])
        XCTAssertEqual("1", params["imp[0]"])
        XCTAssertEqual("t1", params["tid"])
    }

    func testConfigCustomPropertiesAreSentAndViewPropertiesWin() {
        let params = parameters(.Click, nil, customProperties: ["shared": "view"])
        XCTAssertEqual("ios", params["cp.app"])
        XCTAssertEqual("view", params["cp.shared"])
    }

    func testPromotionsBodyKeepsOrderAndEncodesIds() {
        let body = CroboxAPIServices.shared.promotionsBody(productIds: ["c", "a", "b&x=1", "50%+"])
        XCTAssertEqual("0=c&1=a&2=b%26x%3D1&3=50%25%2B", body)
        XCTAssertEqual("", CroboxAPIServices.shared.promotionsBody(productIds: nil))
    }

    func testViewCounterIsUniqueAcrossConcurrentCalls() async {
        let queryParams = RequestQueryParams(viewId: UUID(), pageType: .PageOverview)
        let values = await withTaskGroup(of: Int.self, returning: [Int].self) { group in
            for _ in 0..<1000 {
                group.addTask { queryParams.viewCounter() }
            }
            return await group.reduce(into: []) { $0.append($1) }
        }
        XCTAssertEqual(1000, Set(values).count)
    }

    func testCancellationIsDetected() {
        XCTAssertTrue(Crobox.isCancellation(CancellationError()))
        XCTAssertTrue(Crobox.isCancellation(URLError(.cancelled)))
        XCTAssertTrue(Crobox.isCancellation(CroboxErrors.internalError(msg: "x", cause: URLError(.cancelled))))
        XCTAssertFalse(Crobox.isCancellation(URLError(.timedOut)))
        XCTAssertFalse(Crobox.isCancellation(CroboxErrors.httpError(statusCode: 500)))
    }

    func testErrorMessageLeavesOutRequestUrl() {
        let url = "https://api.crobox.com/promotions?uid=secret-user&cp.email=a@b.c"
        let error = URLError(.timedOut, userInfo: [NSURLErrorFailingURLStringErrorKey: url,
                                                   NSURLErrorFailingURLErrorKey: URL(string: url)!])
        let message = Crobox.errorMessage(CroboxErrors.internalError(msg: "Promotion request failure", cause: error))
        XCTAssertFalse(message.contains("secret-user"), message)
        XCTAssertTrue(message.contains("\(URLError.Code.timedOut.rawValue)"), message)
    }

    func testPersistentVisitorId() {
        let defaults = UserDefaults(suiteName: "crobox-tests-\(UUID().uuidString)")!
        let first = CroboxConfig.persistentVisitorId(defaults: defaults)
        XCTAssertEqual(first, CroboxConfig.persistentVisitorId(defaults: defaults))
        CroboxConfig.resetPersistentVisitorId(defaults: defaults)
        XCTAssertNotEqual(first, CroboxConfig.persistentVisitorId(defaults: defaults))
    }
}

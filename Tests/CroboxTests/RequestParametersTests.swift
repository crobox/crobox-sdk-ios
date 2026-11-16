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

    func testPageViewImpressionsCarryIdPositionQuantityAndList() {
        var impressions = (0..<12).map { ProductParams(productId: "p\($0)") }
        impressions[1] = ProductParams(productId: "p1", quantity: 2, list: "search results")
        let params = parameters(.PageView, PageViewParams(pageTitle: nil, product: nil, searchTerms: nil,
                                                          impressions: impressions, customProperties: nil))
        XCTAssertEqual("p0", params["imp[0].id"])
        XCTAssertEqual("1", params["imp[0].pos"])
        XCTAssertNil(params["imp[0].qty"])
        XCTAssertNil(params["imp[0].lst"])
        XCTAssertEqual("2", params["imp[1].qty"])
        XCTAssertEqual("search results", params["imp[1].lst"])
        XCTAssertEqual("p11", params["imp[11].id"])
        XCTAssertEqual("12", params["imp[11].pos"])
        XCTAssertNil(params["imp[0]"])
        XCTAssertNil(params["[0]"])
    }

    func testProductDetailSendsListNameAndNoPrice() {
        let params = parameters(.PageView, PageViewParams(pageTitle: nil, product: ProductParams(productId: "1", list: "related"),
                                                          searchTerms: nil, impressions: nil, customProperties: nil),
                                pageType: .PageDetail)
        XCTAssertEqual("1", params["pi"])
        XCTAssertEqual("related", params["lst"])
        XCTAssertNil(params["price"])
    }

    func testTimezoneIsUtcOffsetInHoursAsTheSnippetSendsIt() {
        let winter = Date(timeIntervalSince1970: 1_767_225_600) // 2026-01-01
        let summer = Date(timeIntervalSince1970: 1_782_864_000) // 2026-07-01
        XCTAssertEqual("1", CroboxAPIServices.timezoneOffsetHours(TimeZone(identifier: "Europe/Amsterdam")!, at: winter))
        XCTAssertEqual("2", CroboxAPIServices.timezoneOffsetHours(TimeZone(identifier: "Europe/Amsterdam")!, at: summer))
        XCTAssertEqual("5.5", CroboxAPIServices.timezoneOffsetHours(TimeZone(identifier: "Asia/Kolkata")!, at: winter))
        XCTAssertEqual("5.75", CroboxAPIServices.timezoneOffsetHours(TimeZone(identifier: "Asia/Kathmandu")!, at: winter))
        XCTAssertEqual("-5", CroboxAPIServices.timezoneOffsetHours(TimeZone(identifier: "America/New_York")!, at: winter))
        XCTAssertEqual("-3.5", CroboxAPIServices.timezoneOffsetHours(TimeZone(identifier: "America/St_Johns")!, at: winter))
        XCTAssertEqual("0", CroboxAPIServices.timezoneOffsetHours(TimeZone(identifier: "UTC")!, at: winter))
        XCTAssertNotNil(parameters(.Click, nil)["tz"])
        XCTAssertNil(parameters(.Click, nil)["cc"])
    }

    func testConfiguredTimezoneWins() {
        Crobox.shared.initConfig(config: CroboxConfig(containerId: "xlrc9t", visitorId: UUID(),
                                                      timezone: TimeZone(identifier: "Asia/Kolkata")))
        XCTAssertEqual("5.5", parameters(.Click, nil)["tz"])
    }

    func testCheckoutSendsProductsAndCheckoutPageType() {
        let params = parameters(.Checkout, CheckoutParams(products: [ProductParams(productId: "1"), ProductParams(productId: "2")],
                                                          step: "1", customProperties: nil),
                                pageType: .PageOther)
        XCTAssertEqual("pageview", params["t"])
        XCTAssertEqual("5", params["pt"])
        XCTAssertEqual("1", params["imp[0].id"])
        XCTAssertEqual("2", params["imp[1].id"])
    }

    func testPurchaseSendsProductsAndCompletePageType() {
        let params = parameters(.Purchase, PurchaseParams(products: [ProductParams(productId: "1", quantity: 3)], transactionId: "t1",
                                                          affiliation: nil, coupon: nil, revenue: 1.0, customProperties: nil),
                                pageType: .PageOther)
        XCTAssertEqual("pageview", params["t"])
        XCTAssertEqual("6", params["pt"])
        XCTAssertEqual("1", params["imp[0].id"])
        XCTAssertEqual("3", params["imp[0].qty"])
        XCTAssertEqual("t1", params["tid"])
        XCTAssertEqual("1.0", params["rev"])
    }

    func testClickCartAndCustomEventsSendNoPrice() {
        XCTAssertNil(parameters(.Click, ClickQueryParams(productId: "1", quantity: 1))["price"])
        XCTAssertEqual("2", parameters(.AddCart, CartQueryParams(productId: "1", quantity: 2))["qty"])
        XCTAssertEqual("1", parameters(.CustomEvent, CustomQueryParams(name: "x", productId: "1"))["pi"])
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

    func testErrorEventSendsLineOnlyWhenGiven() {
        let withoutLine = parameters(.Error, ErrorQueryParams(tag: "sdk", name: "promotions", message: "HTTP 500"))
        XCTAssertEqual("sdk", withoutLine["tg"])
        XCTAssertEqual("promotions", withoutLine["nm"])
        XCTAssertNil(withoutLine["l"])
        XCTAssertEqual("42", parameters(.Error, ErrorQueryParams(line: 42))["l"])
    }

    func testRequestsTimeOutWithinSeconds() {
        let configuration = APIRequests.sessionConfiguration()
        XCTAssertEqual(15, configuration.timeoutIntervalForRequest)
        XCTAssertEqual(30, configuration.timeoutIntervalForResource)
    }

    func testPersistentVisitorId() {
        let defaults = UserDefaults(suiteName: "crobox-tests-\(UUID().uuidString)")!
        let first = CroboxConfig.persistentVisitorId(defaults: defaults)
        XCTAssertEqual(first, CroboxConfig.persistentVisitorId(defaults: defaults))
        CroboxConfig.resetPersistentVisitorId(defaults: defaults)
        XCTAssertNotEqual(first, CroboxConfig.persistentVisitorId(defaults: defaults))
    }
}

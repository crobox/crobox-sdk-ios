@testable import Crobox
import XCTest

final class PromotionTests: XCTestCase {
    
    let overviewView = ViewContext(viewId: UUID(), viewType: .overview, customProperties: ["test":"async"])
    static var visitorId: UUID = UUID.init()
    
    override class func setUp() {
        Crobox.shared.configure(CroboxConfig(containerId: "xlrc9t", visitorId: visitorId, localeCode: LocaleCode("en_US")))
        Crobox.shared.isLoggingEnabled = true
    }
    
    override func tearDown() async throws {
        try await Task.sleep(nanoseconds: 100_000_000)
    }
    
    func testPromotionsNoProduct() async throws {
        let checkoutView = ViewContext(viewId: UUID(), viewType: .checkout)
        let result = await Crobox.shared.promotions(placementId: 1, view: checkoutView)
        
        switch result {
        case let .success(response):
            XCTAssertNotNil(response.context.sessionId)
            XCTAssertEqual(PromotionTests.visitorId, response.context.visitorId)
            
        case .failure(_):
            XCTFail()
        }
    }
    
    func testPromotionsOneProduct() async throws {
        let detailView = ViewContext(viewId: UUID(), viewType: .detail)
        let result = await Crobox.shared.promotions(placementId: 1,
                                                    view: detailView,
                                                    productIds: ["1"])
        switch result {
        case let .success(response):
            XCTAssertNotNil(response.context.sessionId)
            XCTAssertEqual(PromotionTests.visitorId, response.context.visitorId)
            printAll(response)
        case .failure(_):
            XCTFail()
        }
    }
    
    func testPromotionsMultiProducts() async throws {
        let result = await Crobox.shared.promotions(placementId: 1,
                                                    view: overviewView,
                                                    productIds: ["product1", "product2", "product3", "product4"])
        switch result {
        case let .success(response):
            printAll(response)
            let context = response.context
            XCTAssertNotNil(context.sessionId)
            XCTAssertEqual(PromotionTests.visitorId, context.visitorId)
        case .failure(_):
            XCTFail()
        }
    }
    
    private func printAll(_ response: PromotionsResponse) {
        let context = response.context
        let p = context.visitorId
        print("VisitorId: \(p)")
        for c in context.campaigns {
            print("\tCampaign:[Id: \(c.id), Name: \(c.name)]")
        }
        print("Promotions: \(response.promotions.count)")
        for p in response.promotions {
            print("Id: \(p.id.uuidString)")
            print("Product: \(p.productId ?? "")")
            print("Campaign Id: \(p.campaignId)")
            print("Config: \(p.content?.config ?? [:])")
            
            switch p.content?.component() {
            case .imageBadge(let badge):
                print("Image: \(badge.imageUrl)")
                print("AltText: \(badge.altText ?? "")")
            case .textBadge(let badge):
                print("Text: \(badge.text)")
            case .secondaryMessaging(let messaging):
                print("Secondary Text: \(messaging.text)")
            case nil:
                print("n/a")
            }
        }
    }
    
}

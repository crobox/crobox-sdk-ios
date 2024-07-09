@testable import Crobox
import XCTest

final class PromotionTests: XCTestCase {
    
    let overviewPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageOverview, customProperties: ["test":"async"])
    
    override class func setUp() {
        Crobox.shared.initConfig(config: CroboxConfig(containerId: "xlrc9t", visitorId: UUID.init(), localeCode: .en_US))
        Crobox.shared.isDebug = false
    }
    
    override class func tearDown() {
        Crobox.shared.isDebug = false
    }
    
    func testPromotionsNoProduct() async throws {
        let expectation = XCTestExpectation(description: "receive successful response")
        
        let checkoutPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageCheckout)
        let _ = await Crobox.shared.promotions(placeholderId: "21", queryParams: checkoutPageParams) { result in
            switch result {
            case let .success(response):
                if let p = response.context?.visitorId {
                    print("id: \(p)")
                }
            case let .failure(error):
                print(error)
            }
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    func testPromotionsOneProduct() async throws {
        let expectation = XCTestExpectation(description: "receive successful response")
        
        let detailPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageDetail)
        let _ = await Crobox.shared.promotions(placeholderId: "30",
                                               queryParams: detailPageParams,
                                               productIds: ["29883481"]) { result in
            switch result {
            case let .success(response):
                if let p = response.context?.visitorId {
                    print("id: \(p)")
                }
            case let .failure(error):
                print(error)
            }
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 5.0)
        
    }
    
    
    func testPromotionsMultiProducts() async throws {
        let expectation = XCTestExpectation(description: "receive successful response")
        
        let _ = await Crobox.shared.promotions(placeholderId: "30",
                                               queryParams: overviewPageParams,
                                               productIds: ["29883481", "04133050", "3A626400"]) { result in
            switch result {
            case let .success(p):
                print("id: \(p.promotions[2].id ?? "")")
                print("campaignId: \(String(describing: p.promotions[2].campaignId))")
                print( "productId: \(p.promotions[2].productId ?? "")")
                print( "variantId: \(p.promotions[2].variantId ?? -1)")
                print( "content.id: \(p.promotions[2].content?.id ?? "")")
                print( "content.config: \(p.promotions[2].content?.config?.data ?? [:])")
    
            case let .failure(error):
                print(error)
            }
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    func testPromotionsError() async throws {
        let expectation = XCTestExpectation(description: "receive error response")
        
        let brokenConfig = CroboxConfig(containerId: "9999", visitorId: UUID.init(), localeCode: .en_US)
        Crobox.shared.initConfig(config: brokenConfig)
        
        let _ = await Crobox.shared.promotions(placeholderId: "30",
                                               queryParams: overviewPageParams,
                                               productIds: ["29883481", "04133050", "3A626400"]) { result in
            switch result {
            case let .success(p):
                print(p)
            case let .failure(error):
                print(error)
            }
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
}

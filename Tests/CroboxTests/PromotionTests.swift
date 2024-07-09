@testable import Crobox
import XCTest

final class PromotionTests: XCTestCase {
    
    let overviewPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageOverview, customProperties: ["test":"async"])
    static var visitorId: UUID = UUID.init()
    
    override class func setUp() {
        Crobox.shared.initConfig(config: CroboxConfig(containerId: "xlrc9t", visitorId: visitorId, localeCode: .en_US))
        Crobox.shared.isDebug = true
    }
    
    override func tearDown() async throws {
        try await Task.sleep(for: .milliseconds(100), tolerance: .seconds(0.5))
    }
    
    func skipped_testPromotionsNoProduct() async throws {
        let expectation = XCTestExpectation(description: "receive successful response")
        
        let checkoutPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageCheckout)
        let _ = await Crobox.shared.promotions(placeholderId: "21", queryParams: checkoutPageParams) { result in
            switch result {
            case let .success(response):
                if let _ = response.context?.visitorId {
                    expectation.fulfill()
                }
            case let .failure(error):
                print(error)
            }
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    func skipped_testPromotionsOneProduct() async throws {
        let expectation = XCTestExpectation(description: "receive successful response")
        
        let detailPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageDetail)
        let _ = await Crobox.shared.promotions(placeholderId: "30",
                                               queryParams: detailPageParams,
                                               productIds: ["29883481"]) { result in
            switch result {
            case let .success(response):
                if let _ = response.context?.visitorId {
                    expectation.fulfill()
                }
            case let .failure(error):
                print(error)
            }
        }
        await fulfillment(of: [expectation], timeout: 1.0)
        
    }
    
    func skipped_estPromotionsMultiProducts() async throws {
        let expectation = XCTestExpectation(description: "receive successful response")
        
        let _ = await Crobox.shared.promotions(placeholderId: "30",
                                               queryParams: overviewPageParams,
                                               productIds: ["29883481", "04133050", "3A626400"]) { result in
            switch result {
            case let .success(response):
                for p in response.promotions {
                    print("id multip product: \(p.id ?? "")")
                    print("campaignId: \(String(describing: p.campaignId))")
                    print("productId: \(p.productId ?? "")")
                    print("variantId: \(p.variantId ?? -1)")
                    print("content.id: \(p.content?.id ?? "")")
                    print("content.config: \(p.content?.config?.data ?? [:])")
                }
                if let _ = response.context?.visitorId {
                    expectation.fulfill()
                }
            case let .failure(error):
                print(error)
            }
        }
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
}


@testable import Crobox
import XCTest

final class ConstantTests: XCTestCase {
    
    let overviewPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageOverview, customProperties: ["test":"async"])
    
    override class func setUp() {
        Crobox.shared.initConfig(config: CroboxConfig(containerId: "k8d303", visitorId: UUID.init(), localeCode: .en_US))
        Crobox.shared.isDebug = true
    }
    
    override class func tearDown() {
        Crobox.shared.isDebug = false
    }
    
    func testClickEvent() async throws {
        let clickQueryParams = ClickQueryParams(productId: "4")
        let _ = await Crobox.shared.clickEvent(queryParams: overviewPageParams, clickQueryParams: clickQueryParams)
    }
    
    func testAddCartEvent() async throws {
        let addCartQueryParams = CartQueryParams(productId: "3", price: 1.0, quantity: 12)
        let _ = await Crobox.shared.addCartEvent(queryParams: overviewPageParams, addCartQueryParams:addCartQueryParams)
    }
    
    func testRmCartEvent() async throws {
        let rmCartQueryParams = CartQueryParams(productId: "3", price: 1.0, quantity: 12)
        let _ = await Crobox.shared.removeCartEvent(queryParams: overviewPageParams, rmCartQueryParams: rmCartQueryParams)
    }
    
    func testErrorEvent() async throws {
        let errorParams = ErrorQueryParams(tag: "ParsingError", name: "IllegalArgumentException", message: "bad input")
        let _ = await Crobox.shared.errorEvent(queryParams: overviewPageParams, errorQueryParams: errorParams)
    }
    
    func testCustomEvent() async throws {
        let customParams = CustomQueryParams(name: "custom-event", promotionId: UUID(), productId: "3", price: 1.0, quantity: 1)
        let _ = await Crobox.shared.customEvent(queryParams: overviewPageParams, customQueryParams: customParams)
    }
    
    func testPromotionsNoProduct() throws {
        let expectation = XCTestExpectation(description: "receive successful response")
        
        let checkoutPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageCheckout)
        Crobox.shared.promotions(placeholderId: "21", queryParams: checkoutPageParams) { result in
            switch result {
            case let .success(response):
                if let p = response.context?.visitorId {
                    CroboxDebug.shared.printText(text: "id: \(p)")
                    expectation.fulfill()
                }
            case let .error(error):
                print(error)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    
    func testPromotionsOneProduct() throws {
        let expectation = XCTestExpectation(description: "receive successful response")
        
        let detailPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageDetail)
        Crobox.shared.promotions(placeholderId: "30",
                                 queryParams: detailPageParams,
                                 productIds: ["29883481"]) { result in
            switch result {
            case let .success(response):
                if let p = response.context?.visitorId {
                    CroboxDebug.shared.printText(text: "id: \(p)")
                    expectation.fulfill()
                }
            case let .error(error):
                print(error)
            }
            
        }
        wait(for: [expectation], timeout: 2.0)
        
    }
    
    
    func testPromotions() throws {
        let expectation = XCTestExpectation(description: "receive successful response")
        
        let overviewPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageOverview, customProperties: ["test":"test"])
        Crobox.shared.promotions(placeholderId: "30",
                                 queryParams: overviewPageParams,
                                 productIds: ["29883481", "04133050", "3A626400"]) { result in
            switch result {
            case let .success(p):
                CroboxDebug.shared.printText(text: "id: \(p.promotions[2].id ?? "")")
                CroboxDebug.shared.printText(text: "campaignId: \(String(describing: p.promotions[2].campaignId))")
                CroboxDebug.shared.printText(text: "productId: \(p.promotions[2].productId ?? "")")
                CroboxDebug.shared.printText(text: "variantId: \(p.promotions[2].variantId ?? -1)")
                CroboxDebug.shared.printText(text: "content.id: \(p.promotions[2].content?.id ?? "")")
                CroboxDebug.shared.printText(text: "content.config: \(p.promotions[2].content?.config?.data ?? [:])")
                
                expectation.fulfill()
                
            case let .error(error):
                print(error)
            }
            
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testPromotionsError() throws {
        let expectation = XCTestExpectation(description: "receive error response")
        
        let overviewPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageOverview, customProperties: ["test":"test"])
        Crobox.shared.promotions(placeholderId: "30",
                                 queryParams: overviewPageParams,
                                 productIds: ["29883481", "04133050", "3A626400"]) { result in
            switch result {
            case let .success(p):
                print(p)
            case let .error(error):
                print(error)
                expectation.fulfill()
            }
            
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
}

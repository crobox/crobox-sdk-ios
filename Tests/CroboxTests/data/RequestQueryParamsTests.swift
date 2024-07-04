@testable import Crobox
import XCTest

final class ConstantTests: XCTestCase {
    
    func testExample() throws {
        let uuid = UUID.init()
        XCTAssertEqual(uuid, RequestQueryParams(viewId: uuid, pageType: PageType.PageCart).viewId)
    }
    
    func testClickEvent() throws {
        Crobox.shared.initConfig(config: CroboxConfig(containerId: "k8d303", visitorId: UUID.init(), localeCode: .en_US))
        
        Crobox.shared.isDebug = false
        let expectation = XCTestExpectation(description: "event sent")
        
        let overviewPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageOverview, customProperties: ["test":"test"])
        
        let clickQueryParams = ClickQueryParams(productId: "4")
        Crobox.shared.clickEvent(queryParams: overviewPageParams, clickQueryParams: clickQueryParams)
        
        
        wait(for: [expectation], timeout: 1.0)
        Crobox.shared.isDebug = false
    }
    
    func testAddCartEvent() throws {
        Crobox.shared.initConfig(config: CroboxConfig(containerId: "k8d303", visitorId: UUID.init(), localeCode: .en_US))
        
        Crobox.shared.isDebug = false
        let expectation = XCTestExpectation(description: "event sent")
        
        let overviewPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageOverview, customProperties: ["test":"test"])
        
        let addCartQueryParams = CartQueryParams(productId: "3", price: 1.0, quantity: 12)
        Crobox.shared.addCartEvent(queryParams: overviewPageParams, addCartQueryParams:addCartQueryParams)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    func testRmCartEvent() throws {
        Crobox.shared.initConfig(config: CroboxConfig(containerId: "k8d303", visitorId: UUID.init(), localeCode: .en_US))
        Crobox.shared.isDebug = false
        let expectation = XCTestExpectation(description: "event sent")
        
        let overviewPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageOverview, customProperties: ["test":"test"])
        
        let rmCartQueryParams = CartQueryParams(productId: "3", price: 1.0, quantity: 12)
        Crobox.shared.removeCartEvent(queryParams: overviewPageParams, rmCartQueryParams: rmCartQueryParams)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    func testErrorEvent() throws {
        Crobox.shared.initConfig(config: CroboxConfig(containerId: "k8d303", visitorId: UUID.init(), localeCode: .en_US))
        Crobox.shared.isDebug = false
        let expectation = XCTestExpectation(description: "event sent")
        
        let overviewPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageOverview, customProperties: ["test":"test"])
        
        let errorParams = ErrorQueryParams(tag: "ParsingError", name: "IllegalArgumentException", message: "bad input")
        Crobox.shared.errorEvent(queryParams: overviewPageParams, errorQueryParams: errorParams)
        
        wait(for: [expectation], timeout: 1.0)
        
    }
    
    func testCustomEvent() throws {
        Crobox.shared.initConfig(config: CroboxConfig(containerId: "k8d303", visitorId: UUID.init(), localeCode: .en_US))
        
        Crobox.shared.isDebug = false
        let expectation = XCTestExpectation(description: "event sent")
        
        let overviewPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageOverview, customProperties: ["test":"test"])
        
        let customParams = CustomQueryParams(name: "custom-event", promotionId: UUID(), productId: "3", price: 1.0, quantity: 1)
        Crobox.shared.customEvent(queryParams: overviewPageParams, customQueryParams: customParams)
        
        wait(for: [expectation], timeout: 2.0)
        
    }
    
    
    func testPromotionsNoProduct() throws {
        Crobox.shared.initConfig(config: CroboxConfig(containerId: "k8d303", visitorId: UUID.init(), localeCode: .en_US))
        
        Crobox.shared.isDebug = false
        
        let expectation = XCTestExpectation(description: "send multi req asynchronously.")
        
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
        Crobox.shared.initConfig(config: CroboxConfig(containerId: "k8d303", visitorId: UUID.init(), localeCode: .en_US))
        
        Crobox.shared.isDebug = false
        
        let detailPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageDetail)
        
        let expectation = XCTestExpectation(description: "send multi req asynchronously.")
        
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
        Crobox.shared.initConfig(config: CroboxConfig(containerId: "k8d303", visitorId: UUID.init(), localeCode: .en_US))
        
        Crobox.shared.isDebug = false
        
        let overviewPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageOverview, customProperties: ["test":"test"])
        
        let expectation = XCTestExpectation(description: "send multi req asynchronously.")
        
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
        Crobox.shared.initConfig(config: CroboxConfig(containerId: "99999", visitorId: UUID.init(), localeCode: .en_US))
        
        Crobox.shared.isDebug = true
        
        let overviewPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageOverview, customProperties: ["test":"test"])
        
        let expectation = XCTestExpectation(description: "send multi req asynchronously.")
        
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

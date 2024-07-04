@testable import Crobox
import XCTest

final class ConstantTests: XCTestCase {

    func testExample() throws {
        let uuid = UUID.init()
        XCTAssertEqual(uuid, RequestQueryParams(viewId: uuid, pageType: PageType.PageCart).viewId)
    }
   
    func test() throws {
        
        let vid = UUID.init()
        print(vid)
        Crobox.shared.initConfig(config: CroboxConfig(containerId: "k8d303", visitorId: vid, localeCode: .en_US))
        
        Crobox.shared.isDebug = true
        
        let overviewPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageOverview, customProperties: ["test":"test"])
                
        let expectation = XCTestExpectation(description: "send multi req asynchronously.")
        
        Crobox.shared.promotions(placeholderId: "30",
                                 queryParams: overviewPageParams,
                                 productIds: ["29883481", "04133050", "3A626400"]) { isSuccess, promotionResponse in
            if let p = promotionResponse {

                print("id: \(p.promotions[2].id)")
                print("campaignId: \(p.promotions[2].campaignId)")
                print("productId: \(p.promotions[2].productId)")
                print("variantId: \(p.promotions[2].variantId)")
                print("content.id: \(p.promotions[2].content?.id)")
                print("content.config: \(p.promotions[2].content?.config?.data)")
                
                
            }
            
            expectation.fulfill()
        
        }
        
        //        /// Requesting for a promotion from a product detail page with another placeholderId for a single product
        //        let detailPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageDetail)
        //        Crobox.shared.promotions(placeholderId: "1",
        //                                 queryParams: detailPageParams,
        //                                 productIds: ["1"]) { isSuccess, promotionResponse in
        //            /// process PromotionResponse
        //
        //        }
        //
        //        /// Requesting for a promotion from Checkout Page with another placeholderId without any product
        //        let checkoutPageParams = RequestQueryParams.init(viewId: UUID(), pageType: .PageCheckout)
        //        Crobox.shared.promotions(placeholderId: "2", queryParams: checkoutPageParams) { isSuccess, promotionResponse in
        //            /// process PromotionResponse
        //        }
        
        
        wait(for: [expectation], timeout: 10.0)
        
    }
    
}

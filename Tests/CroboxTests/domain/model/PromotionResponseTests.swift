@testable import Crobox
import SwiftyJSON
import XCTest

final class PromotionResponseTests: XCTestCase {
    
    func testPromotionsError() async throws {
        let jsonStr = """
            {
                "context": {
                    "experiments": [
                        {
                            "control": false,
                            "id": 1,
                            "name": "Campaign 1",
                            "variantId": 1,
                            "variantName": "Crobox"
                        },
                        {
                            "control": false,
                            "id": 2,
                            "name": "Campaign 2",
                            "variantId": 1,
                            "variantName": "Crobox"
                        }
                    ],
                    "groupName": "Campaign 1 : Crobox + Campaign 2: Crobox",
                    "pid": "722D78A6-ADA6-4E03-B903-2F6869185912",
                    "sid": "1DC4FE32-B2CE-4A84-A85F-50AF738226F9"
                },
                "promotions": [
                    {
                        "campaignId": 1,
                        "content": {
                            "component": "component1.tsx",
                            "config": {
                                "Text1_color": "#aaaaaa",
                                "Text1_text": "Campaign 1 text"
                            },
                            "id": "dd737bf6-0223-48e8-b102-b680265219ef"
                        },
                        "experimentId": 1,
                        "id": "821037e1-42a6-11ef-b765-a7995e01acd0",
                        "productId": "Product1",
                        "variantId": 1
                    },
                    {
                        "campaignId": 2,
                        "content": {
                            "component": "component2.tsx",
                            "config": {
                                "Text1_color": "#ffffff",
                                "Text1_text": "Campaign 2 text"
                            },
                            "id": "94d31690-f4be-4e77-9f26-c711d3c7b258"
                        },
                        "experimentId": 2,
                        "id": "820fe9a0-42a6-11ef-b765-a7995e01acd0",
                        "parameters": {},
                        "productId": "Product2",
                        "variantId": 1
                    }
                ]
            }
        """.trimmingCharacters(in: .whitespaces)
        
        let json = JSON(parseJSON: jsonStr)
        let promotionResponse = try PromotionResponse(jsonData: json)
        
        XCTAssertEqual(UUID(uuidString: "722D78A6-ADA6-4E03-B903-2F6869185912"), promotionResponse.context.visitorId)
        XCTAssertEqual(UUID(uuidString: "1DC4FE32-B2CE-4A84-A85F-50AF738226F9"), promotionResponse.context.sessionId)
        XCTAssertEqual("Campaign 1 : Crobox + Campaign 2: Crobox", promotionResponse.context.groupName)
        let campaign1 = promotionResponse.context.campaigns.filter { c in c.id == 1}.first
        XCTAssertEqual(1, campaign1?.id)
        XCTAssertEqual(1, campaign1?.variantId)
        XCTAssertEqual(false, campaign1?.control)
        XCTAssertEqual("Campaign 1", campaign1?.name)
        XCTAssertEqual("Crobox", campaign1?.variantName)
        let campaign2 = promotionResponse.context.campaigns.filter { c in c.id == 2}.first
        XCTAssertEqual(2, campaign2?.id)
        XCTAssertEqual(1, campaign2?.variantId)
        XCTAssertEqual(false, campaign2?.control)
        XCTAssertEqual("Campaign 2", campaign2?.name)
        XCTAssertEqual("Crobox", campaign2?.variantName)
        if let promotion1 = promotionResponse.promotions.filter { p in p.campaignId == 1}.first {
            XCTAssertEqual(UUID(uuidString: "821037e1-42a6-11ef-b765-a7995e01acd0"), promotion1.id)
            XCTAssertEqual(1, promotion1.campaignId)
            XCTAssertEqual(1, promotion1.variantId)
            XCTAssertEqual("Product1", promotion1.productId)
            XCTAssertEqual("component1.tsx", promotion1.content?.component)
            XCTAssertEqual("dd737bf6-0223-48e8-b102-b680265219ef", promotion1.content?.messageId)
            XCTAssertEqual("#aaaaaa", promotion1.content?.config["Text1_color"])
            XCTAssertEqual("Campaign 1 text", promotion1.content?.config["Text1_text"])
            
        }
        if let promotion2 = promotionResponse.promotions.filter { p in p.campaignId == 2}.first {
            XCTAssertEqual(UUID(uuidString: "820fe9a0-42a6-11ef-b765-a7995e01acd0"), promotion2.id)
            XCTAssertEqual(2, promotion2.campaignId)
            XCTAssertEqual(1, promotion2.variantId)
            XCTAssertEqual("Product2", promotion2.productId)
            XCTAssertEqual("component2.tsx", promotion2.content?.component)
            XCTAssertEqual("94d31690-f4be-4e77-9f26-c711d3c7b258", promotion2.content?.messageId)
            XCTAssertEqual("#ffffff", promotion2.content?.config["Text1_color"])
            XCTAssertEqual("Campaign 2 text", promotion2.content?.config["Text1_text"])
            
        }
    }
    
}


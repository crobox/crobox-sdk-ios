@testable import Crobox
import XCTest

final class PromotionsResponseTests: XCTestCase {
    
    func testPromotionsResponse() async throws {
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

        let jsonData = jsonStr.data(using: .utf8)!
        let promotionResponse = try! JSONDecoder().decode(PromotionsResponse.self, from: jsonData)

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
        if let promotion1 = promotionResponse.promotions.filter ({ p in p.campaignId == 1}).first {
            XCTAssertEqual(UUID(uuidString: "821037e1-42a6-11ef-b765-a7995e01acd0"), promotion1.id)
            XCTAssertEqual(1, promotion1.campaignId)
            XCTAssertEqual(1, promotion1.variantId)
            XCTAssertEqual("Product1", promotion1.productId)
            XCTAssertEqual("component1.tsx", promotion1.content?.componentName)
            XCTAssertEqual("dd737bf6-0223-48e8-b102-b680265219ef", promotion1.content?.messageId)
            XCTAssertEqual("#aaaaaa", promotion1.content?.config["Text1_color"])
            XCTAssertEqual("Campaign 1 text", promotion1.content?.config["Text1_text"])
            
        }
        if let promotion2 = promotionResponse.promotions.filter({ p in p.campaignId == 2}).first {
            XCTAssertEqual(UUID(uuidString: "820fe9a0-42a6-11ef-b765-a7995e01acd0"), promotion2.id)
            XCTAssertEqual(2, promotion2.campaignId)
            XCTAssertEqual(1, promotion2.variantId)
            XCTAssertEqual("Product2", promotion2.productId)
            XCTAssertEqual("component2.tsx", promotion2.content?.componentName)
            XCTAssertEqual("94d31690-f4be-4e77-9f26-c711d3c7b258", promotion2.content?.messageId)
            XCTAssertEqual("#ffffff", promotion2.content?.config["Text1_color"])
            XCTAssertEqual("Campaign 2 text", promotion2.content?.config["Text1_text"])
        }
    }
    
    private func promotionContent(_ component: String, _ config: [String: String]) throws -> PromotionContent {
        let json = try JSONSerialization.data(withJSONObject: ["component": component, "config": config])
        return try JSONDecoder().decode(PromotionContent.self, from: json)
    }

    func testImageBadge() throws {
        let content = try promotionContent("MobAppImageBadgeTsx", ["image": "//cdn.crobox.io/content/xlrc9t/Image.png",
                                                          "altText": "Image alt text"])
        guard case .imageBadge(let badge) = content.component() else {
            return XCTFail("Expected an image badge")
        }
        XCTAssertEqual(URL(string: "https://cdn.crobox.io/content/xlrc9t/Image.png"), badge.imageUrl)
        XCTAssertEqual("Image alt text", badge.altText)
    }

    func testImageBadgeKeepsAFullUrl() throws {
        let content = try promotionContent("MobAppImageBadgeTsx", ["image": "https://example.com/badge.png"])
        guard case .imageBadge(let badge) = content.component() else {
            return XCTFail("Expected an image badge")
        }
        XCTAssertEqual(URL(string: "https://example.com/badge.png"), badge.imageUrl)
        XCTAssertNil(badge.altText)
    }

    func testTextBadge() throws {
        let content = try promotionContent("MobAppTextBadgeTsx", ["text": "Best Seller",
                                                         "fontColor": "#ffffff",
                                                         "backgroundColor": "#aaaaaa",
                                                         "borderColor": "#bbbbbb"])
        guard case .textBadge(let badge) = content.component() else {
            return XCTFail("Expected a text badge")
        }
        XCTAssertEqual("Best Seller", badge.text)
        XCTAssertEqual("#ffffff", badge.fontColorValue)
        XCTAssertEqual("#aaaaaa", badge.backgroundValue)
        XCTAssertEqual("#bbbbbb", badge.borderColorValue)
    }

    func testSecondaryMessaging() throws {
        let content = try promotionContent("MobAppSecondaryMessagingTsx", ["text": "Best Seller", "fontColor": "#ffffff"])
        guard case .secondaryMessaging(let messaging) = content.component() else {
            return XCTFail("Expected secondary messaging")
        }
        XCTAssertEqual("Best Seller", messaging.text)
        XCTAssertEqual("#ffffff", messaging.fontColorValue)
    }

    func testComponentIsNilForOtherComponentsOrWithoutItsContent() throws {
        XCTAssertNil(try promotionContent("component1.tsx", ["text": "Best Seller"]).component())
        XCTAssertNil(try promotionContent("MobAppTextBadgeTsx", ["fontColor": "#ffffff"]).component())
        XCTAssertNil(try promotionContent("MobAppImageBadgeTsx", ["altText": "Image alt text"]).component())
    }

#if canImport(UIKit)

    func testTextBadgeColors() throws {
        let content = try promotionContent("MobAppTextBadgeTsx", ["text": "Best Seller",
                                                         "fontColor": "#00ff00",
                                                         "borderColor": "#0000ff"])
        guard case .textBadge(let badge) = content.component() else {
            return XCTFail("Expected a text badge")
        }
        XCTAssertEqual(UIColor.green, badge.fontColor)
        XCTAssertEqual(UIColor.blue, badge.borderColor)
    }

    func testSecondaryMessagingColor() throws {
        let content = try promotionContent("MobAppSecondaryMessagingTsx", ["text": "Best Seller", "fontColor": "#000000"])
        guard case .secondaryMessaging(let messaging) = content.component() else {
            return XCTFail("Expected secondary messaging")
        }
        XCTAssertEqual(true, messaging.fontColor?.isBlack)
    }

#endif

    func testOneInvalidPromotionDoesNotDropTheOthers() throws {
        let jsonStr = """
            {
                "context": {
                    "pid": "722D78A6-ADA6-4E03-B903-2F6869185912",
                    "sid": "1DC4FE32-B2CE-4A84-A85F-50AF738226F9"
                },
                "promotions": [
                    { "id": "not-a-uuid", "campaignId": 1 },
                    42,
                    { "id": "820fe9a0-42a6-11ef-b765-a7995e01acd0", "campaignId": 2, "productId": "Product2" }
                ]
            }
        """
        let response = try JSONDecoder().decode(PromotionsResponse.self, from: jsonStr.data(using: .utf8)!)
        XCTAssertEqual(1, response.promotions.count)
        XCTAssertEqual("Product2", response.promotions.first?.productId)
    }

    func testNonStringConfigValuesDoNotEmptyTheConfig() throws {
        let jsonStr = """
            {
                "id": "dd737bf6-0223-48e8-b102-b680265219ef",
                "component": "MobAppTextBadgeTsx",
                "config": {
                    "text": "Best Seller",
                    "Text1_color": "#aaaaaa",
                    "fontSize": 12,
                    "opacity": 0.5,
                    "visible": true,
                    "missing": null,
                    "nested": { "a": "b" }
                }
            }
        """
        let content = try JSONDecoder().decode(PromotionContent.self, from: jsonStr.data(using: .utf8)!)
        XCTAssertEqual("Best Seller", content.config["text"])
        XCTAssertEqual("#aaaaaa", content.config["Text1_color"])
        XCTAssertEqual("12", content.config["fontSize"])
        XCTAssertEqual("0.5", content.config["opacity"])
        XCTAssertEqual("true", content.config["visible"])
        XCTAssertNil(content.config["missing"])
        XCTAssertNil(content.config["nested"])
        guard case .textBadge(let badge) = content.component() else {
            return XCTFail("Expected a text badge")
        }
        XCTAssertEqual("Best Seller", badge.text)
    }
}


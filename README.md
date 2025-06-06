# crobox-sdk-ios
Crobox SDK for iOS

[![Build Status](https://github.com/crobox/crobox-sdk-ios/actions/workflows/ci.yml/badge.svg)](https://github.com/crobox/crobox-sdk-ios/actions?query=main)
[![Official Crobox project](https://img.shields.io/badge/project-official-green.svg?colorA=303033&colorB=ff8a2c&label=Crobox)](https://crobox.com/)
![GitHub Release](https://img.shields.io/github/v/release/crobox/crobox-sdk-ios?include_prereleases)

This is an asynchronous SDK kit for consuming Crobox API for iOS applications, written in Swift.

First add the dependency to your project:


## Installation

### Swift Package Manager

```swift
// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "YOUR_PROJECT_NAME",
    dependencies: [
        .package(url: "https://github.com/crobox/crobox-sdk-ios.git", from: "{{ latest_version }}"),
    ]
)
```

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website.
To integrate Crobox into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
 pod 'croboxSDK', '~> 1.0.32'
```

## Start using Crobox SDK

First configure and create a `Crobox` singleton as:

```swift
Crobox.shared.initConfig(config: CroboxConfig(containerId: "xlhvci", visitorId: UUID.init(), localeCode: .en_US))
```

`RequestQueryParams` contains page specific parameters, shared by all requests sent from the same page/view.
It must be recreated when the page/view is displayed.
```swift
let detailPageParams = RequestQueryParams.init(viewId: UUID(), pageType : .PageDetail, customProperties: ["test":"test"])
```

For sending events, use the `xyzEvent` APIs exposed by the Crobox instance.
Events might also take event specific parameters:

```swift
var addCartQueryParams = CartQueryParams(productId: "abc")
addCartQueryParams.price = 2.0
addCartQueryParams.quantity = 3
Crobox.shared.addCartEvent(queryParams: detailPageParams, addCartQueryParams: addCartQueryParams)
```

For retrieving promotions for zero, one or more products, use the specific PlaceholderId that was already configured with specific page types and linked to campaigns via Crobox Admin App.

```swift
        let result = await Crobox.shared.promotions(placeholderId: "1",
                                                    queryParams: overviewPageParams,
                                                    productIds: ["1", "2", "3"])
        switch result {
        case let .success(p):
            print("id: \(p.promotions[2].id ?? "")")
            print("campaignId: \(String(describing: p.promotions[2].campaignId))")
            print("productId: \(p.promotions[2].productId ?? "")")
            print("variantId: \(p.promotions[2].variantId ?? -1)")
            print("content.id: \(p.promotions[2].content?.id ?? "")")
            print("content.config: \(p.promotions[2].content?.config?.data ?? [:])")
        case let .failure(error):
            print(error)
        }

```


## Promotion Response Schema

```swift
        let result = await Crobox.shared.promotions(placeholderId: "1",
                                                    queryParams: overviewPageParams,
                                                    productIds: ["1", "2", "3"])
        switch result {
        case let .success(response):
            let context = response.context
            let promotions = response.promotions
            
            let visitorId = context.visitorId
            let sessionId = context.sessionId
            let groupName = context.groupName
            for campaign in context.campaigns {
                let campaignId = campaign.id
                let campaignName = campaign.name
                let variantId = campaign.variantId
                let variantName = campaign.variantName
                let control = campaign.control
            }
            for promotion in response.promotions {
                let promotionId = promotion.id
                let campaignId = promotion.campaignId
                let variantId = promotion.variantId
                let productId = promotion.productId
                if let content = promotion.content {
                    let messageId = content.messageId
                    let componentName = content.componentName
                    let configMap = content.config
                    for c in configMap {
                        let configKey = c.key
                        let configValue = c.value
                    }
                    let imageBadge = content.getImageBadge()
                    let textBadge = content.getTextBadge()
                               
                    let conf = p.content?.contentConfig()
                    switch conf {
                    case let conf as ImageBadge:
                        let image = conf.image
                        let altText = conf.altText
                    case let conf as TextBadge:
                        let text = conf.text
                        let fontColor = conf.fontColor ?? ""
                        let background = conf.backgroundColor ?? ""
                        let borderColor = conf.borderColor ?? ""

                        let fontUIColor = conf.fontUIColor() ?? UIColor.clear
                        let backgroundUIColor = conf.backgroundUIColor() ?? UIColor.clear
                        let borderUIColor = conf.borderUIColor() ?? UIColor.clear

                    case let conf as SecondaryMessaging:
                        let text = conf.text
                        let fontColor = conf.fontColor ?? ""
                        let fontUIColor = conf.fontUIColor() ?? UIColor.clear

                    default:
                        //
                    }
                }
            }
        
        case let .failure(error):
            print(error)
        }
```

### PromotionsResponse

| Name       | Type             | Description                       |
|------------|------------------|-----------------------------------|
| context    | PromotionContext | The context about campaigns       |
| promotions | List<Promotion>  | The list of promotions calculated |

### PromotionContext

| Name      | Type           | Description                                      |
|-----------|----------------|--------------------------------------------------|
| sessionId | UUID           | Session ID                                       |
| visitorId | UUID           | Visitor ID                                       |
| groupName | String?        | The list of campaign and variant names, combined |
| campaigns | List<Campaign> | The list of ongoing campaigns                    |

### Campaign

| Name        | Type    | Description                                                                                                                                                                                                                                         |
|-------------|---------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| id          | String  | Campaign ID                                                                                                                                                                                                                                         |
| name        | String  | Campaign Name                                                                                                                                                                                                                                       |
| variantId   | String  | There is a ratio that determines the amount of traffic exposed to this campaign (or is allocated to the control group) between Crobox and Control group. Variant id refers to the variant which this promotion belongs to and is used for debugging |
| variantName | String  | Name of the Campaign Variant                                                                                                                                                                                                                        |  
| control     | Boolean | Indicates if the variant is allocated to the control group                                                                                                                                                                                          |

### Promotion

| Name       | Type              | Description                                          |
|------------|-------------------|------------------------------------------------------|
| id         | String            | Unique id for this promotion                         |
| productId  | String?           | Product ID if requested                              |
| campaignId | Int               | The campaign which this promotion belongs to         |
| variantId  | Int               | ID of the variant that this promotion is assigned to |
| content    | PromotionContent? | Promotion Content                                    |

### PromotionContent

| Name          | Type                | Description                                                                                                                                                |
|---------------|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------|
| messageId     | String              | As Campaigns might have alternative messages, Message Id identifies the message assigned to this promotion                                                 |
| component     | String              | Component Name                                                                                                                                             |
| config        | Map<String, String> | Map of all visual configuration items, managed via Crobox Admin app. <br/>Example:<br/> ```Map("Text1_text" : "Best Seller", "Text1_color" : "#0e1111")``` |
| getTextBadge  | TextBadge?          | Returns a Text Badge if a text component exists with the following pre-defined keys: "text", "fontColor", "backgroundColor" and "borderColor"              |
| getImageBadge | ImageBadge?         | Returns an Image Badge if an image component exists with the following pre-defined keys: "image" and "altText"                                             |
| contentConfig | PromotionContentConfig | Returns either an Image Badge, a Text Badge or a Secondary Messaging component |

### TextBadge

| Name            | Type        | Description               |
|-----------------|-------------|---------------------------|
| text            | String      | Text message              |
| fontColor       | String      | Font color                |
| backgroundColor | String?     | Optional background color |
| borderColor     | String?     | Optional border color     |


### ImageBadge

| Name    | Type    | Description    |
|---------|---------|----------------|
| image   | String  | Image url      |
| altText | String? | Alternate text |


### Secondary Messaging

| Name            | Type        | Description               |
|-----------------|-------------|---------------------------|
| text            | String      | Text message              |
| fontColor       | String      | Font color                |

## Samples
 
See [test app](app/app/CroboxApp.swift) to see details of Crobox SDK usage.

### List of screens
The application includes test UI for the next pages:  <br/>
**List of Products page**  - display list of test products with test promotion and banners<br/>
**Product Details page**  - display product images, description and available variants.<br/>
**Product Basket page**  - display list of products in a user basket<br/>
**Checkout page**  - dialog with checkout data<br/>
**Purchase page** - final confirmation to complete purchase

### List of Events
Sample App sends Crobox event requests for the next scenarios:  <br/>
**onClickEvent**  - used to track click events at object/ specific area.<br/>
```swift
CroboxEventManager.shared.onClickEvent(product)
```
**onPageViewEvent**  - used to track page view events, for example list of products, product details, checkout, etc.<br/>
```swift
CroboxEventManager.shared.onPageViewEvent(pageName: "basket")
```
**onAddToCartEvent**  - used to track analytics when the user add products to the basket<br/>
```swift
CroboxEventManager.shared.onAddToCartEvent(product, quantity: 1)
```
**onRemoveFromCartEvent**   - used to track analytics when the user removes/delete products to the basket<br/>
```swift
CroboxEventManager.shared.onRemoveFromCartEvent(product, quantity: 1)
```
**onCheckoutEvent**  - used to track checkout page<br/>
```swift
CroboxEventManager.shared.onCheckoutEvent(basketItems)
```
**onPurchaseEvent**  - used to track final confirmation for purchase<br/>
```swift
CroboxEventManager.shared.onPurchaseEvent(purchasedItems)
```

### Get Promotion
The app executes **Crobox.shared.promotions** request to get a list of test promotions. These test promotions can be shown   
as a banner to notify end user about "Sales", and "Ads" about specific products.

### Sample data
Sample project uses test products and test data sources to visualize the general flow of E-Commerce application.   
That's why the application operates with a simplified set of data models, like:<br/>   
**Product** data model - specific Object that user can purchase  <br/>
**BasketItem** data model - elements that the user puts into Basket.

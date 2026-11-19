# crobox-sdk-ios
Crobox SDK for iOS

[![Build Status](https://github.com/crobox/crobox-sdk-ios/actions/workflows/ci.yml/badge.svg)](https://github.com/crobox/crobox-sdk-ios/actions?query=main)
[![Official Crobox project](https://img.shields.io/badge/project-official-green.svg?colorA=303033&colorB=ff8a2c&label=Crobox)](https://crobox.com/)
![GitHub Release](https://img.shields.io/github/v/release/crobox/crobox-sdk-ios?include_prereleases)

This is an asynchronous SDK kit for consuming Crobox API for iOS applications, written in Swift.

## Installation

The SDK is distributed with Swift Package Manager and needs iOS 16 or later.

In Xcode, choose **File → Add Package Dependencies…**, enter `https://github.com/crobox/crobox-sdk-ios.git`
and add the `Crobox` library to your app target.

In a `Package.swift`, add the package and the `Crobox` product:

```swift
dependencies: [
    .package(url: "https://github.com/crobox/crobox-sdk-ios.git", from: "1.1.0"),
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "Crobox", package: "crobox-sdk-ios"),
    ]),
]
```

Then import it where you use it:

```swift
import Crobox
```

The SDK is no longer published to CocoaPods, because CocoaPods trunk stops accepting new versions in December 2026.

### Upgrading from CocoaPods

1. Remove `pod 'croboxSDK'` from your `Podfile` and run `pod install`.
2. Add the package as described above.
3. Replace `import croboxSDK` with `import Crobox`.

The API also changed in a few places since the CocoaPods releases:

- `LocaleCode` accepts any code, such as `LocaleCode("nl_BE")`, instead of a fixed list (`.en_US`).
- `CroboxConfig` has no `currencyCode`: the currency comes from the region that the locale selects.
- `timezone` is a `TimeZone` instead of an hour offset.
- The `price` fields are gone. Crobox uses the prices from your product feed.
- `PurchaseParams` requires a `transactionId`.
- Pass a stable `visitorId`, such as `CroboxVisitor.visitorId()`, instead of a new `UUID()` on every launch.

## Start using Crobox SDK

First configure and create a `Crobox` singleton as:

```swift
Crobox.shared.configure(CroboxConfig(containerId: "xlhvci",
                                     visitorId: CroboxVisitor.visitorId(),
                                     localeCode: LocaleCode("en_US")))
```

The `visitorId` must stay the same across app launches. Campaign and control assignment is keyed on it,
so creating a new `UUID()` on every launch puts the user in a different variant each time and makes the A/B results unusable.
`CroboxVisitor.visitorId()` creates an id on first use and stores it in `UserDefaults`.
If your app already stores its own visitor id, pass that instead.
Call `CroboxVisitor.reset()` if a visitor should start over, for example on logout. It stores a new id and returns it.

The `localeCode` selects the region of the Container (country, language and currency). If the Container has
several regions, set it to the region the user is shopping in, for example `LocaleCode("nl_BE")` or
`LocaleCode.of(Locale.current)`, and update it when the user switches:
```swift
Crobox.shared.config.localeCode = LocaleCode("nl_BE")
```
The device time zone is sent automatically. To use a different one, set `timezone`, for example
`TimeZone(identifier: "Europe/Amsterdam")`.

`ViewContext` contains view specific parameters, shared by all requests sent from the same view.
Create **one** `ViewContext` (with a new `viewId`) each time a screen is displayed, and use it for the view event
and for every promotions request and event on that screen. The server counts every new `viewId` as a view,
so a new `viewId` per request double-counts views, and one `viewId` for the whole app merges all screens into one view.
```swift
let detailView = ViewContext(viewId: UUID(), viewType: .detail, customProperties: ["test":"test"])
```

For sending events, use the `xyzEvent` APIs exposed by the Crobox instance.
Events might also take event specific parameters:

```swift
let cartParams = CartParams(productId: "abc", quantity: 3)
Crobox.shared.addToCartEvent(view: detailView, params: cartParams)
```

Pass the products shown in a view as `impressions`, in the order they are shown; their position is taken from that order.
A purchase is only recorded with a `transactionId`.

For retrieving promotions for zero, one or more products, use the specific `placementId` that was already configured with specific view types and linked to campaigns via Crobox Admin App.
Pass the product ids in the order they are displayed: the server ranks promotions in that order.

```swift
        let result = await Crobox.shared.promotions(placementId: 1,
                                                    view: overviewView,
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
        let result = await Crobox.shared.promotions(placementId: 1,
                                                    view: overviewView,
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
                    switch content.component() {
                    case .textBadge(let badge):
                        badgeLabel.text = badge.text
                        badgeLabel.textColor = badge.fontColor
                        // The background, a plain color or a gradient, as a layer for the badge's view
                        let backgroundLayer = badge.backgroundLayer()
                    case .imageBadge(let badge):
                        let imageUrl = badge.imageUrl
                        let altText = badge.altText
                    case .secondaryMessaging(let messaging):
                        messageLabel.text = messaging.text
                        messageLabel.textColor = messaging.fontColor
                    case nil:
                        break
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
| componentName | String              | Name of the campaign's component, as a module name, e.g. `MobAppTextBadgeTsx`                                                                              |
| config        | Map<String, String> | Map of all visual configuration items, managed via Crobox Admin app. <br/>Example:<br/> ```Map("Text1_text" : "Best Seller", "Text1_color" : "#0e1111")``` |
| component()   | PromotionComponent? | What the promotion shows when the campaign uses an App component: `.textBadge` (`MobAppTextBadgeTsx`), `.imageBadge` (`MobAppImageBadgeTsx`) or `.secondaryMessaging` (`MobAppSecondaryMessagingTsx`), otherwise nil |

### TextBadge

| Name              | Type     | Description                                                                                         |
|-------------------|----------|-----------------------------------------------------------------------------------------------------|
| text              | String   | The text                                                                                            |
| fontColor         | UIColor? | The text's color                                                                                    |
| borderColor       | UIColor? | The border's color                                                                                  |
| backgroundLayer() | CALayer? | The background, a plain color or a gradient, as a layer that fills its bounds, or nil when there is none |

The background is set in the App as a color, or as a gradient with its gradient input. Gradients look as they do in the
App's preview: a linear gradient's angle runs clockwise from the bottom up (90deg runs from left to right), and a radial
gradient runs from the center out to the farthest corner. For example, behind a badge's label:

```swift
final class BadgeView: UIView {
    private var backgroundLayer: CALayer?

    func show(_ badge: TextBadge) {
        backgroundLayer?.removeFromSuperlayer()
        backgroundLayer = badge.backgroundLayer()
        if let backgroundLayer {
            backgroundLayer.cornerRadius = 4
            backgroundLayer.contentsScale = traitCollection.displayScale
            layer.insertSublayer(backgroundLayer, at: 0)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundLayer?.frame = bounds
    }
}
```

### ImageBadge

| Name     | Type    | Description                                 |
|----------|---------|---------------------------------------------|
| imageUrl | URL     | The image's URL                             |
| altText  | String? | Text that describes the image, for VoiceOver |

### Secondary Messaging

| Name      | Type     | Description      |
|-----------|----------|------------------|
| text      | String   | The text         |
| fontColor | UIColor? | The text's color |


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
**onViewEvent**  - used to track view events, for example list of products, product details, checkout, etc.<br/>
```swift
CroboxEventManager.shared.onViewEvent(title: "basket")
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

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to run the tests and how to release.

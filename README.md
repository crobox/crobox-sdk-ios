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
 pod 'croboxSDK', '~> 1.0.22'
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
        await Crobox.shared.promotions(placeholderId: "1",
                                       queryParams: overviewPageParams,
                                       productIds: ["1", "2", "3"]) { result in
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
        }

```

## Samples

See [test snippet](app/app/ViewController.swift) for various samples


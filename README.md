# crobox-sdk-android
Crobox SDK for iOS

[![Official Crobox project](https://img.shields.io/badge/project-official-green.svg?colorA=303033&colorB=ff8a2c&label=Crobox)](https://crobox.com/)
[![Crobox](https://img.shields.io/badge/Crobox-ios-white)](http://docs.crobox.com)
[![GitHub License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](http://www.apache.org/licenses/LICENSE-2.0)

This is an asynchronous SDK kit for consuming Crobox API for iOS applications, written in Swift.

First add the dependency to your project:

```swift

```

## Start using Crobox SDK

First configure and create a `Crobox` singleton as:

```swift

```

RequestQueryParams contains page specific parameters, shared by all requests fired from the same page/view.
It must be recreated when the page/view is displayed, and reused between all requests fired from the same page.
```swift

```

For sending events, use the `xyzEvent` APIs exposed by the Crobox instance.
Events might also take event specific parameters:

```swift

```

For retrieving promotions for a single or more products, use the specific PlaceholderId that is configured with specific page types and linked to campaigns via Crobox Admin App.

```swift

```

## Samples

See [test app](app/CroboxTestApp/ViewController.swift) for various samples


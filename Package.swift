// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Crobox",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(name: "Crobox",targets: ["Crobox"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.9.1")),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.0.0"),
    ],
    targets: [
        .target(name: "Crobox", dependencies: ["Alamofire", "SwiftyJSON"]),
        .testTarget(name: "CroboxTests", dependencies: ["Crobox"]),
    ]
)

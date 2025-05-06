// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Crobox",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v16)
    ],
    products: [
        .library(name: "Crobox",targets: ["Crobox"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "Crobox", dependencies: []),
        .testTarget(name: "CroboxTests", dependencies: ["Crobox"]),
    ]
)

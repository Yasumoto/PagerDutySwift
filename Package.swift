// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "PagerDutySwift",
    products: [
        .library(
            name: "PagerDutySwift",
            targets: ["PagerDutySwift"])
    ],
    dependencies: [
        // 🚀 Low-level network framework
        .package(url: "https://github.com/apple/swift-nio", from: "2.0.0"),

        // 🏎 HTTP Client built on NIO
        .package(url: "https://github.com/swift-server/swift-nio-http-client.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "PagerDutySwift",
            dependencies: ["NIOFoundationCompat", "NIOHTTP1", "NIOHTTPClient"]),
        .testTarget(
            name: "PagerDutySwiftTests",
            dependencies: ["PagerDutySwift"])
    ]
)

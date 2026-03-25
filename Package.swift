// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BitchatNostr",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "BitchatNostr",
            targets: ["BitchatNostr"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/bitchat-sdk/BitLogger.git", from: "0.1.0"),
        .package(url: "https://github.com/bitchat-sdk/BitchatProtocol.git", from: "0.1.0"),
        .package(url: "https://github.com/21-DOT-DEV/swift-secp256k1", exact: "0.21.1")
    ],
    targets: [
        .target(
            name: "BitchatNostr",
            dependencies: [
                .product(name: "BitLogger", package: "BitLogger"),
                .product(name: "BitchatProtocol", package: "BitchatProtocol"),
                .product(name: "P256K", package: "swift-secp256k1")
            ],
            path: "Sources/BitchatNostr",
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .testTarget(
            name: "BitchatNostrTests",
            dependencies: ["BitchatNostr"],
            path: "Tests/BitchatNostrTests",
            swiftSettings: [.swiftLanguageMode(.v5)]
        )
    ]
)

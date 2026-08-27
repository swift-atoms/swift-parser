// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-parser",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Parser",
            targets: ["Parser"]
        ),
        .library(
            name: "Parser Standard Library Integration",
            targets: ["Parser Standard Library Integration"]
        ),
        .library(
            name: "Parser Apple Foundation Integration",
            targets: ["Parser Apple Foundation Integration"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-either.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-product.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-input.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-collection.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-index.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-text.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Parser",
            dependencies: [
                .product(name: "Either", package: "swift-either"),
                .product(name: "Product", package: "swift-product"),
                .product(name: "Input", package: "swift-input"),
                .product(name: "Collection", package: "swift-collection"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Text", package: "swift-text"),
            ]
        ),
        .target(
            name: "Parser Standard Library Integration",
            dependencies: ["Parser"]
        ),
        .target(
            name: "Parser Apple Foundation Integration",
            dependencies: [
                "Parser",
                "Parser Standard Library Integration",
            ]
        ),
        .testTarget(
            name: "Parser Tests",
            dependencies: ["Parser"],
            path: "Tests/Parser Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}

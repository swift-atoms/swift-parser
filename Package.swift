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
        .library(name: "Parser", targets: ["Parser"]),
        .library(name: "Parser Witness", targets: ["Parser Witness"]),
        .library(name: "Parser Error", targets: ["Parser Error"]),
        .library(name: "Parser Map", targets: ["Parser Map"]),
        .library(name: "Parser FlatMap", targets: ["Parser FlatMap"]),
        .library(name: "Parser Skip", targets: ["Parser Skip"]),
        .library(name: "Parser Product", targets: ["Parser Product"]),
        .library(name: "Parser Sequence", targets: ["Parser Sequence"]),
        .library(
            name: "Parser Standard Library Integration",
            targets: ["Parser Standard Library Integration"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-either.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-pair.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(name: "Parser"),
        .target(
            name: "Parser Witness",
            dependencies: [.target(name: "Parser")]
        ),
        .target(
            name: "Parser Error",
            dependencies: [.target(name: "Parser")]
        ),
        .target(
            name: "Parser Map",
            dependencies: [
                .target(name: "Parser"),
                .product(name: "Either", package: "swift-either"),
            ]
        ),
        .target(
            name: "Parser FlatMap",
            dependencies: [
                .target(name: "Parser"),
                .product(name: "Either", package: "swift-either"),
            ]
        ),
        .target(
            name: "Parser Skip",
            dependencies: [
                .target(name: "Parser"),
                .product(name: "Either", package: "swift-either"),
            ]
        ),
        .target(
            name: "Parser Product",
            dependencies: [
                .target(name: "Parser"),
                .product(name: "Either", package: "swift-either"),
                .product(name: "Pair", package: "swift-pair"),
            ]
        ),
        .target(
            name: "Parser Sequence",
            dependencies: [.target(name: "Parser")]
        ),
        .target(
            name: "Parser Standard Library Integration",
            dependencies: [.target(name: "Parser")]
        ),
        .testTarget(
            name: "Parser Tests",
            dependencies: [.target(name: "Parser")]
        ),
        .testTarget(
            name: "Parser Witness Tests",
            dependencies: [
                .target(name: "Parser"),
                .target(name: "Parser Witness"),
            ]
        ),
        .testTarget(
            name: "Parser Error Tests",
            dependencies: [
                .target(name: "Parser"),
                .target(name: "Parser Error"),
                .target(name: "Parser Map"),
                .product(name: "Either", package: "swift-either"),
            ]
        ),
        .testTarget(
            name: "Parser Map Tests",
            dependencies: [
                .target(name: "Parser"),
                .target(name: "Parser Map"),
                .product(name: "Either", package: "swift-either"),
            ],
            resources: [.copy("Fixtures")]
        ),
        .testTarget(
            name: "Parser FlatMap Tests",
            dependencies: [
                .target(name: "Parser"),
                .target(name: "Parser FlatMap"),
                .product(name: "Either", package: "swift-either"),
            ]
        ),
        .testTarget(
            name: "Parser Skip Tests",
            dependencies: [
                .target(name: "Parser"),
                .target(name: "Parser Skip"),
                .product(name: "Either", package: "swift-either"),
            ]
        ),
        .testTarget(
            name: "Parser Product Tests",
            dependencies: [
                .target(name: "Parser"),
                .target(name: "Parser Map"),
                .target(name: "Parser Product"),
                .target(name: "Parser Skip"),
                .target(name: "Parser Sequence"),
                .product(name: "Either", package: "swift-either"),
                .product(name: "Pair", package: "swift-pair"),
            ]
        ),
        .testTarget(
            name: "Parser Sequence Tests",
            dependencies: [
                .target(name: "Parser"),
                .target(name: "Parser Sequence"),
                .target(name: "Parser Skip"),
                .product(name: "Either", package: "swift-either"),
            ]
        ),
        .testTarget(
            name: "Parser Standard Library Integration Tests",
            dependencies: [
                .target(name: "Parser"),
                .target(name: "Parser Standard Library Integration"),
                .target(name: "Parser Sequence"),
            ]
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

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
        .library(name: "Parser Match", targets: ["Parser Match"]),
        .library(name: "Parser Map", targets: ["Parser Map"]),
        .library(name: "Parser FlatMap", targets: ["Parser FlatMap"]),
        .library(name: "Parser Filter", targets: ["Parser Filter"]),
        .library(name: "Parser Skip", targets: ["Parser Skip"]),
        .library(name: "Parser Take", targets: ["Parser Take"]),
        .library(name: "Parser Fail", targets: ["Parser Fail"]),
        .library(name: "Parser Trace", targets: ["Parser Trace"]),
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
            url: "https://github.com/swift-atoms/swift-predicate.git",
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
            name: "Parser Match",
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
            name: "Parser Filter",
            dependencies: [
                .target(name: "Parser"),
                .product(name: "Either", package: "swift-either"),
                .product(name: "Predicate", package: "swift-predicate"),
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
            name: "Parser Take",
            dependencies: [.target(name: "Parser")]
        ),
        .target(
            name: "Parser Fail",
            dependencies: [.target(name: "Parser")]
        ),
        .target(
            name: "Parser Trace",
            dependencies: [.target(name: "Parser")]
        ),
        .target(
            name: "Parser Standard Library Integration",
            dependencies: [
                .target(name: "Parser"),
                .target(name: "Parser Match"),
            ]
        ),
        .testTarget(
            name: "Parser Tests",
            dependencies: [.target(name: "Parser")]
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
            name: "Parser Filter Tests",
            dependencies: [
                .target(name: "Parser"),
                .target(name: "Parser Filter"),
                .product(name: "Either", package: "swift-either"),
                .product(name: "Predicate", package: "swift-predicate"),
            ]
        ),
        .testTarget(
            name: "Parser Fail Tests",
            dependencies: [
                .target(name: "Parser Fail"),
                .target(name: "Parser Match"),
            ]
        ),
        .testTarget(
            name: "Parser Standard Library Integration Tests",
            dependencies: [
                .target(name: "Parser"),
                .target(name: "Parser Standard Library Integration"),
                .target(name: "Parser Take"),
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

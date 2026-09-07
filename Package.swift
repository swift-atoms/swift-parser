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
        .library(name: "Parser Standard Library Integration", targets: ["Parser Standard Library Integration"]),
        .library(name: "Parser Foundation Library Integration", targets: ["Parser Foundation Library Integration"]),
        .library(name: "Parser Test Support", targets: ["Parser Test Support"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-either.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Parser",
            dependencies: [
                .product(name: "Either", package: "swift-either"),
            ],
            path: "Sources/Parser"
        ),
        .target(
            name: "Parser Standard Library Integration",
            dependencies: [
                .target(name: "Parser"),
            ],
            path: "Sources/Parser Standard Library Integration"
        ),
        .target(
            name: "Parser Foundation Library Integration",
            dependencies: [
                .target(name: "Parser"),
                .target(name: "Parser Standard Library Integration"),
            ],
            path: "Sources/Parser Foundation Library Integration"
        ),
        .target(
            name: "Parser Test Support",
            dependencies: [
                .target(name: "Parser"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Parser Tests",
            dependencies: [
                .target(name: "Parser"),
                .product(name: "Either", package: "swift-either"),
                .target(name: "Parser Standard Library Integration"),
                .target(name: "Parser Test Support"),
                .target(name: "Parser Foundation Library Integration"),
            ],
            path: "Tests/Parser Tests",
            resources: [.copy("Fixtures")]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets {
    target.swiftSettings = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
}

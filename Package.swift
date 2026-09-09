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
        .library(name: "Parser Foundation Integration", targets: ["Parser Foundation Integration"]),
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
            name: "Parser Foundation Integration",
            dependencies: [
                .target(name: "Parser"),
            ],
            path: "Sources/Parser Foundation Integration"
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
                .target(name: "Parser Test Support"),
                .target(name: "Parser Foundation Integration"),
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
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("MoveOnlyTuples"),
    ]
}

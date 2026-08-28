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
            name: "Parser Primitive",
            targets: ["Parser Primitive"]
        ),
        .library(
            name: "Parser",
            targets: ["Parser"]
        ),
        .library(
            name: "Parser Core",
            targets: ["Parser Core"]
        ),
        .library(
            name: "Parser Remaining",
            targets: ["Parser Remaining"]
        ),
        .library(
            name: "Parser Tagged",
            targets: ["Parser Tagged"]
        ),

        .library(
            name: "Parser Witness",
            targets: ["Parser Witness"]
        ),
        .library(
            name: "Parser Error",
            targets: ["Parser Error"]
        ),
        .library(
            name: "Parser Match",
            targets: ["Parser Match"]
        ),
        .library(
            name: "Parser EndOfInput",
            targets: ["Parser EndOfInput"]
        ),
        .library(
            name: "Parser Constraint",
            targets: ["Parser Constraint"]
        ),
        .library(
            name: "Parser OneOf",
            targets: ["Parser OneOf"]
        ),
        .library(
            name: "Parser Map",
            targets: ["Parser Map"]
        ),
        .library(
            name: "Parser Conversion",
            targets: ["Parser Conversion"]
        ),
        .library(
            name: "Parser FlatMap",
            targets: ["Parser FlatMap"]
        ),
        .library(
            name: "Parser Filter",
            targets: ["Parser Filter"]
        ),
        .library(
            name: "Parser Conditional",
            targets: ["Parser Conditional"]
        ),
        .library(
            name: "Parser Optional",
            targets: ["Parser Optional"]
        ),
        .library(
            name: "Parser Skip",
            targets: ["Parser Skip"]
        ),
        .library(
            name: "Parser Many",
            targets: ["Parser Many"]
        ),
        .library(
            name: "Parser Take",
            targets: ["Parser Take"]
        ),
        .library(
            name: "Parser Pair",
            targets: ["Parser Pair"]
        ),
        .library(
            name: "Parser Consume",
            targets: ["Parser Consume"]
        ),
        .library(
            name: "Parser Discard",
            targets: ["Parser Discard"]
        ),
        .library(
            name: "Parser Prefix",
            targets: ["Parser Prefix"]
        ),
        .library(
            name: "Parser First",
            targets: ["Parser First"]
        ),
        .library(
            name: "Parser Tracked",
            targets: ["Parser Tracked"]
        ),
        .library(
            name: "Parser Spanned",
            targets: ["Parser Spanned"]
        ),
        .library(
            name: "Parser Span",
            targets: ["Parser Span"]
        ),
        .library(
            name: "Parser Locate",
            targets: ["Parser Locate"]
        ),
        .library(
            name: "Parser Peek",
            targets: ["Parser Peek"]
        ),
        .library(
            name: "Parser Not",
            targets: ["Parser Not"]
        ),
        .library(
            name: "Parser Always",
            targets: ["Parser Always"]
        ),
        .library(
            name: "Parser Fail",
            targets: ["Parser Fail"]
        ),
        .library(
            name: "Parser Rest",
            targets: ["Parser Rest"]
        ),
        .library(
            name: "Parser End",
            targets: ["Parser End"]
        ),
        .library(
            name: "Parser Lazy",
            targets: ["Parser Lazy"]
        ),
        .library(
            name: "Parser Trace",
            targets: ["Parser Trace"]
        ),
        .library(
            name: "Parser Parse",
            targets: ["Parser Parse"]
        ),
        .library(
            name: "Parser Conformance",
            targets: ["Parser Conformance"]
        ),
        .library(
            name: "Parser Test Support",
            targets: ["Parser Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-molecules/swift-either.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-pair.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-product.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-input.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-array.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-collection.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-index.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-text.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-tagged.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-iterator.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Parser Primitive",
            dependencies: []
        ),

        .target(
            name: "Parser Core",
            dependencies: [
                "Parser Primitive",
                "Parser Remaining",
                "Parser Tagged",
                "Parser Witness",
                .product(name: "Input", package: "swift-input"),
                .product(name: "Array", package: "swift-array"),
            ]
        ),

        .target(
            name: "Parser Remaining",
            dependencies: [
                "Parser Primitive",
                .product(name: "Collection", package: "swift-collection"),
            ]
        ),
        .target(
            name: "Parser Tagged",
            dependencies: [
                "Parser Primitive",
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),

        .target(
            name: "Parser Witness",
            dependencies: [
                "Parser Primitive"
            ]
        ),

        .target(
            name: "Parser Error",
            dependencies: [
                "Parser Primitive",
                .product(name: "Either", package: "swift-either"),
                .product(name: "Text", package: "swift-text"),
                .product(name: "Index", package: "swift-index"),
            ]
        ),
        .target(
            name: "Parser Match",
            dependencies: [
                "Parser Primitive",
                "Parser Remaining",
                "Parser Error",
            ]
        ),

        .target(
            name: "Parser EndOfInput",
            dependencies: [
                "Parser Primitive"
            ]
        ),
        .target(
            name: "Parser Constraint",
            dependencies: [
                "Parser Primitive"
            ]
        ),

        .target(
            name: "Parser OneOf",
            dependencies: [
                "Parser Primitive",
                "Parser Error",
                .product(name: "Input", package: "swift-input"),
                .product(name: "Product", package: "swift-product"),
            ]
        ),
        .target(
            name: "Parser Map",
            dependencies: [
                "Parser Primitive",
                "Parser Error",
            ]
        ),
        .target(
            name: "Parser Conversion",
            dependencies: [
                "Parser Primitive",
                "Parser Error",
            ]
        ),
        .target(
            name: "Parser FlatMap",
            dependencies: [
                "Parser Primitive",
                "Parser Error",
            ]
        ),
        .target(
            name: "Parser Filter",
            dependencies: [
                "Parser Primitive",
                "Parser Constraint",
                "Parser Error",
            ]
        ),
        .target(
            name: "Parser Conditional",
            dependencies: [
                "Parser Primitive",
                "Parser Error",
            ]
        ),
        .target(
            name: "Parser Optional",
            dependencies: [
                "Parser Primitive",
                .product(name: "Input", package: "swift-input"),
            ]
        ),
        .target(
            name: "Parser Skip",
            dependencies: [
                "Parser Primitive",
                "Parser Error",
            ]
        ),
        .target(
            name: "Parser Many",
            dependencies: [
                "Parser Primitive",
                "Parser Take",
                .product(name: "Input", package: "swift-input"),
            ]
        ),
        .target(
            name: "Parser Take",
            dependencies: [
                "Parser Primitive",
                "Parser Error",
                "Parser Skip",
                "Parser Conditional",
                "Parser Optional",
                "Parser Always",
                .product(name: "Collection", package: "swift-collection"),
                .product(name: "Input", package: "swift-input"),
            ]
        ),
        .target(
            name: "Parser Pair",
            dependencies: [
                "Parser Primitive",
                "Parser Error",
                .product(name: "Pair", package: "swift-pair"),
            ]
        ),

        .target(
            name: "Parser Consume",
            dependencies: [
                "Parser Primitive",
                "Parser Constraint",
                .product(name: "Collection", package: "swift-collection"),
            ]
        ),
        .target(
            name: "Parser Discard",
            dependencies: [
                "Parser Primitive",
                "Parser Constraint",
                "Parser Consume",
                .product(name: "Collection", package: "swift-collection"),
            ]
        ),

        .target(
            name: "Parser Prefix",
            dependencies: [
                "Parser Primitive",
                "Parser Constraint",
                "Parser Match",
                .product(name: "Collection", package: "swift-collection"),
            ]
        ),

        .target(
            name: "Parser First",
            dependencies: [
                "Parser Primitive",
                "Parser Match",
                "Parser EndOfInput",
                .product(name: "Input", package: "swift-input"),
            ]
        ),

        .target(
            name: "Parser Tracked",
            dependencies: [
                "Parser Primitive",
                "Parser Error",
                .product(name: "Input", package: "swift-input"),
            ]
        ),
        .target(
            name: "Parser Spanned",
            dependencies: [
                "Parser Primitive",
                .product(name: "Index", package: "swift-index"),
            ]
        ),
        .target(
            name: "Parser Span",
            dependencies: [
                "Parser Primitive",
                "Parser Error",
                "Parser Tracked",
                "Parser Spanned",
                .product(name: "Input", package: "swift-input"),
            ]
        ),
        .target(
            name: "Parser Locate",
            dependencies: [
                "Parser Primitive",
                "Parser Error",
                "Parser Tracked",
                .product(name: "Input", package: "swift-input"),
            ]
        ),

        .target(
            name: "Parser Peek",
            dependencies: [
                "Parser Primitive",
                .product(name: "Input", package: "swift-input"),
            ]
        ),
        .target(
            name: "Parser Not",
            dependencies: [
                "Parser Primitive",
                "Parser Match",
                .product(name: "Input", package: "swift-input"),
            ]
        ),

        .target(
            name: "Parser Always",
            dependencies: [
                "Parser Primitive"
            ]
        ),
        .target(
            name: "Parser Fail",
            dependencies: [
                "Parser Primitive"
            ]
        ),
        .target(
            name: "Parser Rest",
            dependencies: [
                "Parser Primitive",
                .product(name: "Collection", package: "swift-collection"),
            ]
        ),
        .target(
            name: "Parser End",
            dependencies: [
                "Parser Primitive",
                "Parser Remaining",
                "Parser Match",
            ]
        ),

        .target(
            name: "Parser Lazy",
            dependencies: [
                "Parser Primitive"
            ]
        ),
        .target(
            name: "Parser Trace",
            dependencies: [
                "Parser Primitive"
            ]
        ),
        .target(
            name: "Parser Parse",
            dependencies: [
                "Parser Primitive"
            ]
        ),

        .target(
            name: "Parser Conformance",
            dependencies: [
                "Parser Primitive",
                "Parser Match",
            ]
        ),

        .target(
            name: "Parser",
            dependencies: [
                "Parser Primitive",
                "Parser Remaining",
                "Parser Tagged",
                "Parser Witness",
                "Parser Error",
                "Parser Match",
                "Parser EndOfInput",
                "Parser Constraint",
                "Parser OneOf",
                "Parser Map",
                "Parser Conversion",
                "Parser FlatMap",
                "Parser Filter",
                "Parser Conditional",
                "Parser Optional",
                "Parser Skip",
                "Parser Many",
                "Parser Take",
                "Parser Pair",
                "Parser Consume",
                "Parser Discard",
                "Parser Prefix",
                "Parser First",
                "Parser Tracked",
                "Parser Spanned",
                "Parser Span",
                "Parser Locate",
                "Parser Peek",
                "Parser Not",
                "Parser Always",
                "Parser Fail",
                "Parser Rest",
                "Parser End",
                "Parser Lazy",
                "Parser Trace",
                "Parser Parse",
                "Parser Conformance",
            ]
        ),

        .target(
            name: "Parser Test Support",
            dependencies: [
                "Parser",
                .product(name: "Input", package: "swift-input"),
                .product(name: "Input Test Support", package: "swift-input"),
                .product(name: "Array Test Support", package: "swift-array"),
                .product(name: "Iterator Chunk", package: "swift-iterator"),
                .product(name: "Iterable", package: "swift-iterator"),
            ],
            path: "Tests/Support"
        ),

        .testTarget(
            name: "Parser Always Tests",
            dependencies: ["Parser Test Support"]
        ),
        .testTarget(
            name: "Parser Consume Tests",
            dependencies: ["Parser Test Support"]
        ),
        .testTarget(
            name: "Parser End Tests",
            dependencies: ["Parser Test Support"]
        ),
        .testTarget(
            name: "Parser Error Tests",
            dependencies: ["Parser Test Support"]
        ),
        .testTarget(
            name: "Parser Fail Tests",
            dependencies: ["Parser Test Support"]
        ),
        .testTarget(
            name: "Parser Filter Tests",
            dependencies: ["Parser Test Support"]
        ),
        .testTarget(
            name: "Parser First Tests",
            dependencies: ["Parser Test Support"]
        ),
        .testTarget(
            name: "Parser FlatMap Tests",
            dependencies: ["Parser Test Support"]
        ),
        .testTarget(
            name: "Parser Many Tests",
            dependencies: ["Parser Test Support"]
        ),
        .testTarget(
            name: "Parser Map Tests",
            dependencies: ["Parser Test Support"]
        ),
        .testTarget(
            name: "Parser Conversion Tests",
            dependencies: ["Parser Test Support"]
        ),
        .testTarget(
            name: "Parser Not Tests",
            dependencies: ["Parser Test Support"]
        ),
        .testTarget(
            name: "Parser OneOf Tests",
            dependencies: ["Parser Test Support"]
        ),
        .testTarget(
            name: "Parser Optional Tests",
            dependencies: ["Parser Test Support"]
        ),
        .testTarget(
            name: "Parser Peek Tests",
            dependencies: ["Parser Test Support"]
        ),
        .testTarget(
            name: "Parser Prefix Tests",
            dependencies: ["Parser Test Support"]
        ),
        .testTarget(
            name: "Parser Rest Tests",
            dependencies: ["Parser Test Support"]
        ),
        .testTarget(
            name: "Parser Spanned Tests",
            dependencies: ["Parser Test Support"]
        ),
        .testTarget(
            name: "Parser Take Tests",
            dependencies: ["Parser Test Support"]
        ),
        .testTarget(
            name: "Parser Pair Tests",
            dependencies: ["Parser Test Support"]
        ),
        .testTarget(
            name: "Parser Invariant Tests",
            dependencies: ["Parser Test Support"]
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

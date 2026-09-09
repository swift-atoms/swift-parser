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
        .library(name: "Parser Test Support", targets: ["Parser Test Support"]),
    ],
    traits: [
        .trait(name: "Repetition", description: "Range-based repetition", enabledTraits: ["Either"]),
        .trait(
            name: "Append",
            description: "Parsing integration for Append",
            enabledTraits: ["Either"]
        ),
        .trait(
            name: "Either",
            description: "Parsing integration for Either"
        ),
        .trait(
            name: "Pair",
            description: "Parsing integration for Pair",
            enabledTraits: ["Either"]
        ),
        .trait(
            name: "Skip",
            description: "Parsing integration for Skip",
            enabledTraits: ["Either"]
        ),
        .trait(
            name: "Always",
            description: "Parsing integration for Always"
        ),
        .trait(
            name: "FlatMap",
            description: "Parsing integration for FlatMap",
            enabledTraits: ["Either"]
        ),
        .trait(
            name: "Lazy",
            description: "Parsing integration for Lazy",
            enabledTraits: ["Either"]
        ),
        .trait(
            name: "Map",
            description: "Parsing integration for Map",
            enabledTraits: ["Either"]
        ),
        .trait(
            name: "Optic",
            description: "Parsing integration for Optic",
            enabledTraits: ["Map"]
        ),
        .trait(
            name: "Predicate",
            description: "Parsing integration for Predicate"
        ),
        .trait(
            name: "Search",
            description: "Parsing integration for Search"
        ),
        .trait(
            name: "Iterator",
            description: "Parsing integration for Iterator"
        ),
        .trait(
            name: "Collection",
            description: "Parsing integration for Collection"
        ),
        .default(
            enabledTraits: [
                "Repetition",
                "Append",
                "Either",
                "Pair",
                "Skip",
                "Always",
                "FlatMap",
                "Lazy",
                "Map",
                "Optic",
                "Predicate",
                "Search",
                "Iterator",
                "Collection"
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-checkpoint.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-cardinal.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-repetition.git", branch: "main"),
        .package(
            url: "https://github.com/swift-atoms/swift-tagged.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-ordinal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-index.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-append.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-either.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-pair.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-skip.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-always.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-flatmap.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-lazy.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-map.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-optic.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-predicate.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-search.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-iterator.git",
            branch: "main",
            traits: ["default", "Search", "Repetition"]
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-collection.git",
            branch: "main",
            traits: ["default", "Search", "Repetition"]
        ),
    ],
    targets: [
        .testTarget(name: "Repetition Parser Tests", dependencies: [.target(name: "Parser")]),
        .target(
            name: "Parser",
            dependencies: [
                .product(name: "Checkpoint", package: "swift-checkpoint", condition: .when(traits: ["Repetition"])),
                .product(name: "Repetition", package: "swift-repetition", condition: .when(traits: ["Repetition"])),
                .product(name: "Cardinal", package: "swift-cardinal", condition: .when(traits: ["Repetition"])),
                .product(name: "Append", package: "swift-append", condition: .when(traits: ["Append"])),
                .product(name: "Either", package: "swift-either", condition: .when(traits: ["Either"])),
                .product(name: "Pair", package: "swift-pair", condition: .when(traits: ["Pair"])),
                .product(name: "Skip", package: "swift-skip", condition: .when(traits: ["Skip"])),
                .product(name: "Always", package: "swift-always", condition: .when(traits: ["Always"])),
                .product(name: "FlatMap", package: "swift-flatmap", condition: .when(traits: ["FlatMap"])),
                .product(name: "Lazy", package: "swift-lazy", condition: .when(traits: ["Lazy"])),
                .product(name: "Map", package: "swift-map", condition: .when(traits: ["Map"])),
                .product(name: "Optic", package: "swift-optic", condition: .when(traits: ["Optic"])),
                .product(name: "Predicate", package: "swift-predicate", condition: .when(traits: ["Predicate"])),
                .product(name: "Search", package: "swift-search", condition: .when(traits: ["Search"])),
                .product(name: "Iterator", package: "swift-iterator", condition: .when(traits: ["Iterator"])),
                .product(name: "Collection", package: "swift-collection", condition: .when(traits: ["Collection"])),
            ]
        ),
        .target(
            name: "Parser Test Support",
            dependencies: [
                .target(name: "Parser"),
                .product(name: "Collection", package: "swift-collection", condition: .when(traits: ["Collection"])),
                .product(name: "Iterator", package: "swift-iterator", condition: .when(traits: ["Iterator"])),
                .product(name: "Index", package: "swift-index", condition: .when(traits: ["Repetition"])),
                .product(name: "Ordinal", package: "swift-ordinal", condition: .when(traits: ["Repetition"])),
                .product(name: "Tagged", package: "swift-tagged", condition: .when(traits: ["Repetition"])),
            ],
            path: "Tests/Support",
            resources: [.copy("Fixtures")]
        ),
        .testTarget(
            name: "Parser Tests",
            dependencies: [
                .target(name: "Parser"),
                .target(name: "Parser Test Support"),
            ]
        ),
        .testTarget(
            name: "Always Parser Tests",
            dependencies: [
                .target(name: "Parser"),
                .target(name: "Parser Test Support"),
            ]
        ),
        .testTarget(
            name: "Append Parser Tests",
            dependencies: [
                .target(name: "Parser"),
                .target(name: "Parser Test Support"),
            ]
        ),
        .testTarget(
            name: "Either Parser Tests",
            dependencies: [
                .target(name: "Parser"),
                .target(name: "Parser Test Support"),
            ]
        ),
        .testTarget(
            name: "FlatMap Parser Tests",
            dependencies: [
                .target(name: "Parser"),
                .target(name: "Parser Test Support"),
            ]
        ),
        .testTarget(
            name: "Lazy Parser Tests",
            dependencies: [
                .target(name: "Parser"),
                .target(name: "Parser Test Support"),
            ]
        ),
        .testTarget(
            name: "Map Parser Tests",
            dependencies: [
                .target(name: "Parser"),
                .target(name: "Parser Test Support"),
            ]
        ),
        .testTarget(
            name: "Optic Parser Tests",
            dependencies: [
                .target(name: "Parser"),
                .target(name: "Parser Test Support"),
            ]
        ),
        .testTarget(
            name: "Pair Parser Tests",
            dependencies: [
                .target(name: "Parser"),
                .target(name: "Parser Test Support"),
            ]
        ),
        .testTarget(
            name: "Predicate Parser Tests",
            dependencies: [
                .target(name: "Parser"),
                .target(name: "Parser Test Support"),
            ]
        ),
        .testTarget(
            name: "Collection Selection Parser Tests",
            dependencies: [
                .target(name: "Parser"),
                .target(name: "Parser Test Support"),
            ]
        ),
        .testTarget(
            name: "Selection Parser Tests",
            dependencies: [
                .target(name: "Parser"),
                .target(name: "Parser Test Support"),
            ]
        ),
        .testTarget(
            name: "Skip Parser Tests",
            dependencies: [
                .target(name: "Parser"),
                .target(name: "Parser Test Support"),
            ]
        ),
        .testTarget(
            name: "Swift Parser Tests",
            dependencies: [
                .target(name: "Parser"),
                .target(name: "Parser Test Support"),
            ]
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

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
        .library(name: "Collection Parser Test Support", targets: ["Collection Parser Test Support"]),
        .library(name: "Cursor Parser Test Support", targets: ["Cursor Parser Test Support"]),
    ],
    traits: [
        .trait(name: "Tagged", description: "Parsing into tagged values"),
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
        .trait(name: "CollectionLeaves", description: "Absorbed CollectionLeaves integration", enabledTraits: ["Collection", "Either"]),
        .trait(name: "IteratorLeaves", description: "Absorbed IteratorLeaves integration", enabledTraits: ["Iterator", "Either"]),
        .trait(name: "Product", description: "Absorbed Product integration", enabledTraits: ["Either"]),
        .trait(name: "Choice", description: "Approved Choice integration", enabledTraits: []),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-checkpoint.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-cardinal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-repetition.git",
            branch: "main"
        ),
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
            traits: [.trait(name: "Search", condition: .when(traits: ["Search"])), .trait(name: "Repetition", condition: .when(traits: ["Repetition"]))]
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-collection.git",
            branch: "main",
            traits: [.trait(name: "Search", condition: .when(traits: ["Search"])), .trait(name: "Repetition", condition: .when(traits: ["Repetition"]))]
        ),
        .package(url: "https://github.com/swift-atoms/swift-product.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-cursor.git", branch: "main"),
    ],
    targets: [
        .testTarget(name: "Repetition Parser Tests", dependencies: [.target(name: "Parser")]),
        .target(
            name: "Parser",
            dependencies: [
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Checkpoint", package: "swift-checkpoint"),
                .product(name: "Repetition", package: "swift-repetition"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Append", package: "swift-append"),.product(name: "Either", package: "swift-either"),
                .product(name: "Pair", package: "swift-pair"),
                .product(name: "Skip", package: "swift-skip"),
                .product(name: "Always", package: "swift-always"),
                .product(name: "FlatMap", package: "swift-flatmap"),
                .product(name: "Lazy", package: "swift-lazy"),
                .product(name: "Map", package: "swift-map"),
                .product(name: "Optic", package: "swift-optic"),
                .product(name: "Predicate", package: "swift-predicate"),
                .product(name: "Search", package: "swift-search"),.product(name: "Iterator", package: "swift-iterator"),.product(name: "Collection", package: "swift-collection"),
                .product(name: "Product", package: "swift-product"),
            ]
        ),
        .target(
            name: "Parser Test Support",
            dependencies: [
                .target(name: "Parser"),
                .product(name: "Collection", package: "swift-collection"),
                .product(name: "Iterator", package: "swift-iterator"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Ordinal", package: "swift-ordinal"),
                .product(name: "Tagged", package: "swift-tagged"),
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
        .testTarget(name: "Absorbed swift-collection-parser Collection Parser End Tests", dependencies: [.product(name: "Collection", package: "swift-collection"), .target(name: "Collection Parser Test Support"), .target(name: "Parser")], path: "Tests/Absorbed/swift-collection-parser/Collection Parser End Tests"),
        .testTarget(name: "Absorbed swift-collection-parser Collection Parser Prefix Tests", dependencies: [.product(name: "Collection", package: "swift-collection"), .target(name: "Collection Parser Test Support"), .target(name: "Parser"), .product(name: "Tagged", package: "swift-tagged")], path: "Tests/Absorbed/swift-collection-parser/Collection Parser Prefix Tests"),
        .testTarget(name: "Absorbed swift-collection-parser Collection Parser Rest Tests", dependencies: [.product(name: "Collection", package: "swift-collection"), .target(name: "Collection Parser Test Support"), .target(name: "Parser")], path: "Tests/Absorbed/swift-collection-parser/Collection Parser Rest Tests"),
        .target(name: "Collection Parser Test Support", dependencies: [.product(name: "Collection", package: "swift-collection"), .product(name: "Index", package: "swift-index"), .product(name: "Iterator", package: "swift-iterator"), .product(name: "Ordinal", package: "swift-ordinal"), .target(name: "Parser"), .product(name: "Tagged", package: "swift-tagged")], path: "Tests/Absorbed/swift-collection-parser/Support"),
        .testTarget(name: "Absorbed swift-iterator-parser Iterator Parser Tests", dependencies: [.product(name: "Either", package: "swift-either"), .product(name: "Iterator", package: "swift-iterator"), .target(name: "Parser")], path: "Tests/Absorbed/swift-iterator-parser/Iterator Parser Tests"),
        .testTarget(name: "Absorbed swift-product-parser Product Parser Tests", dependencies: [.target(name: "Parser")], path: "Tests/Absorbed/swift-product-parser/Product Parser Tests", resources: [.copy("Fixtures")]),
        .testTarget(name: "Approved Cursor Parser FlatMap Tests", dependencies: [.target(name: "Parser"), .product(name: "Always", package: "swift-always"), .product(name: "Checkpoint", package: "swift-checkpoint"), .product(name: "Cursor", package: "swift-cursor"), .target(name: "Cursor Parser Test Support"),
            ], path: "Tests/Approved Cursor Parsing/Cursor Parser FlatMap Tests"),
        .testTarget(name: "Approved Cursor Parser Many Tests", dependencies: [.target(name: "Parser"), .product(name: "Always", package: "swift-always"), .product(name: "Checkpoint", package: "swift-checkpoint"), .product(name: "Cursor", package: "swift-cursor"), .target(name: "Cursor Parser Test Support"),
            ], path: "Tests/Approved Cursor Parsing/Cursor Parser Many Tests"),
        .testTarget(name: "Approved Cursor Parser Peek Tests", dependencies: [.target(name: "Parser"), .product(name: "Checkpoint", package: "swift-checkpoint"), .product(name: "Cursor", package: "swift-cursor"), .target(name: "Cursor Parser Test Support"),
            ], path: "Tests/Approved Cursor Parsing/Cursor Parser Peek Tests"),
        .testTarget(name: "Approved Cursor Parser Invariant Tests", dependencies: [.target(name: "Parser"), .product(name: "Always", package: "swift-always"), .product(name: "Checkpoint", package: "swift-checkpoint"), .product(name: "Cursor", package: "swift-cursor"), .target(name: "Cursor Parser Test Support"), .product(name: "Either", package: "swift-either"),
            ], path: "Tests/Approved Cursor Parsing/Cursor Parser Invariant Tests"),
        .target(name: "Cursor Parser Test Support", dependencies: [.target(name: "Parser"), .product(name: "Cursor", package: "swift-cursor")], path: "Tests/Approved Cursor Parsing/Support"),
        .testTarget(name: "Approved Cursor Parser Optionally Tests", dependencies: [.target(name: "Parser"), .product(name: "Checkpoint", package: "swift-checkpoint"), .product(name: "Cursor", package: "swift-cursor"), .target(name: "Cursor Parser Test Support"),
            ], path: "Tests/Approved Cursor Parsing/Cursor Parser Optionally Tests"),
        .testTarget(name: "Approved Cursor Parser Not Tests", dependencies: [.target(name: "Parser"), .product(name: "Checkpoint", package: "swift-checkpoint"), .product(name: "Cursor", package: "swift-cursor"), .target(name: "Cursor Parser Test Support"),
            ], path: "Tests/Approved Cursor Parsing/Cursor Parser Not Tests"),
        .testTarget(name: "Approved Cursor Parser OneOf Tests", dependencies: [.target(name: "Parser"), .product(name: "Always", package: "swift-always"), .product(name: "Checkpoint", package: "swift-checkpoint"), .product(name: "Cursor", package: "swift-cursor"), .target(name: "Cursor Parser Test Support"),
            ], path: "Tests/Approved Cursor Parsing/Cursor Parser OneOf Tests"),
        .testTarget(name: "Approved Cursor Parser Map Tests", dependencies: [.target(name: "Parser"), .product(name: "Checkpoint", package: "swift-checkpoint"), .product(name: "Cursor", package: "swift-cursor"), .target(name: "Cursor Parser Test Support"),
            ], path: "Tests/Approved Cursor Parsing/Cursor Parser Map Tests"),
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

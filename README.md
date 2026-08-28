# swift-parser

The abstract Parser namespace, protocol, and input-agnostic parser combinators
for Swift.

The package exposes focused products rather than an umbrella product. Depend on
`Parser` for the namespace and protocol, then add only the operations a target
uses, such as `Parser Map` or `Parser Take`.

`Parser Standard Library Integration` contains the parser conformances for
Swift `Array` and `String`, together with `Swift.Optional.Parser` and its result
builder integration.

Input checkpointing, alternatives, repetition, lookahead, and source locations
belong to [`swift-input-parser`](https://github.com/swift-molecules/swift-input-parser).
Collection-specific consumption and matching belong to
[`swift-collection-parser`](https://github.com/swift-molecules/swift-collection-parser).
Pair and Tagged integrations live in
[`swift-pair-parser`](https://github.com/swift-molecules/swift-pair-parser) and
[`swift-tagged-parser`](https://github.com/swift-molecules/swift-tagged-parser).
Directional lifting through Optics belongs to
[`swift-optic-parser`](https://github.com/swift-molecules/swift-optic-parser).

## Installation

```swift
dependencies: [
    .package(
        url: "https://github.com/swift-atoms/swift-parser.git",
        branch: "main"
    ),
]
```

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Parser", package: "swift-parser"),
        .product(name: "Parser Map", package: "swift-parser"),
    ]
)
```

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).

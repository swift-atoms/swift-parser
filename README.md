# Parser

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Parser-combinator primitives for Swift, with a Foundation-free core and narrow standard-library and Apple Foundation integration products.

## Installation

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-atoms/swift-parser.git", branch: "main")
]
```

> Pre-1.0: no version tags yet. APIs may change; pin a commit for reproducible builds.

Add the core product to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Parser", package: "swift-parser")
    ]
)
```

The package preserves the atom three-product shape:

- `Parser` provides the Foundation-free parser core.
- `Parser Standard Library Integration` adds conformances for standard-library collection literals.
- `Parser Apple Foundation Integration` is the only product that imports Foundation.

Requires Swift 6.4+.

## License

Apache 2.0. See [LICENSE](LICENSE).

# Parser

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Parser combinator primitives for Swift — 37 narrow modules spanning byte parsers, combinators (always, backtrack, conditional, constraint, filter, first, lazy, many, not, oneOf, optional, peek, prefix, rest, skip, span, take), and tracing/locating utilities. Each module ships as its own product so consumers depend on exactly the surface they need.

## Installation

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-molecules/swift-parser.git", branch: "main")
]
```

> Pre-1.0: no version tags yet. APIs may change; pin a commit for reproducible builds.

Add the umbrella product to your target (re-exports every module):

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Parser", package: "swift-parser")
    ]
)
```

For narrower compile-time surface, depend on individual variant products such as `Parser Match`, `Parser Span`, or `Parser Constraint`. The full product list is in [Package.swift](Package.swift).

Requires Swift 6.2+.

## License

Apache 2.0. See [LICENSE](LICENSE).

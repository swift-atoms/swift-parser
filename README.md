# swift-parser

`Parser` provides the parsing protocol, function representation, result builder,
standard-library adapters, and optional integrations with the algebra packages.

## Package traits

All traits are enabled by default. There is no aggregate composition trait.

| Trait | Integration |
| --- | --- |
| Always | Constant success and empty builder blocks |
| Append | Sequential tuple accumulation |
| Either | Builder branches |
| Pair | Explicit pairing and noncopyable builder accumulation |
| Skip | Sequential output omission |
| Map | Output and failure mapping |
| FlatMap | Dependent parser composition |
| Lazy | Deferred parsing |
| Optic | Adapter, isomorphism, and prism mapping |
| Predicate | Single-element recognition |
| Prefix | Bounded and predicate/delimiter-based prefix recognition |
| Iterator | Iterator adapters for Predicate and Prefix, alongside those traits |
| Collection | Custom Collection adapters for Prefix, alongside that trait |

Append, Pair, Skip, Map, FlatMap, and Lazy enable Either for typed failure composition.
Optic enables Map. Iterator adapters that combine input and recognition errors
also require Either.

Consumers normally depend on the `Parser` product and `import Parser`. To select
only particular integrations, configure the package dependency explicitly:

```swift
.package(
    url: "https://github.com/swift-atoms/swift-parser.git",
    branch: "main",
    traits: ["Append", "Skip", "Map", "Prefix"]
)
```

Use `traits: []` for the core without integrations. Trait requests are additive
across the dependency graph; another dependency can enable additional traits.

The former Always, Append, Either, Pair, Skip, Map, FlatMap, Lazy, Optic,
Predicate, and Prefix parser packages have been removed. Their implementations and tests now live
in this package; use the `Parser` product and `import Parser`. The general
algebra implementations remain in their own packages.

The legacy `swift-collection-parser`, `swift-cursor-parser`, and
`swift-iterator-parser` APIs have not been migrated. Their responsibility and
overlap cleanup is separate from these integrations.

## Deferred construction

`Lazy` creates a fresh parser on every parse, including after construction fails.
An infallible factory preserves the produced parser's failure type. A throwing
factory reports `Either<FactoryFailure, ParseFailure>`: `.left` for construction
and `.right` for parsing. Construction failure leaves the input untouched.
Factories may produce noncopyable parsers. Parse outputs must be escapable because
the temporary parser is destroyed after each call.

Explicit type annotations now spell `Lazy<Value, FactoryFailure>` and
`Lazy<Value, FactoryFailure>.Parser<Failure>`. Inferred infallible construction
such as `Lazy { parser }` continues to infer `Never` for the factory failure.

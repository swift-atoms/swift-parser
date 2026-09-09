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
| Repetition | Range-based repeated parsing and count/predicate selection |
| Search | Pattern search with explicit boundary projection |
| Iterator | Forward-source adapters for Predicate, Repetition, and Search |
| Collection | Slice adapters for count ranges, repetition, and search |

Append, Pair, Skip, Map, FlatMap, Lazy, and Repetition enable Either for typed failure composition.
Optic enables Map. Iterator adapters that combine input and recognition errors
also require Either.

Consumers normally depend on the `Parser` product and `import Parser`. To select
only particular integrations, configure the package dependency explicitly:

```swift
.package(
    url: "https://github.com/swift-atoms/swift-parser.git",
    branch: "main",
    traits: ["Append", "Skip", "Map", "Repetition", "Search"]
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


## Repetition and failure contracts

`swift-prefix` is retired. Count constraints use standard ranges of Cardinal;
Repetition pairs an operation with those bounds. Search returns match boundaries,
with explicit selection of start (before) or end (through).

```swift
let counts: ClosedRange<Cardinal> = 2...5
let repeated = counts.parser { normalizedRecordParser }
let composed = counts.parser(for: Substring.self) {
    firstNormalizedParser
    secondNormalizedParser
}
let slice = counts.parser(for: Substring.self)
let beforeDelimiter = Search("--").selecting(.start).parser(for: Substring.self)
```

For general parser repetition the operation's failure must explicitly be
`Either<Rejection, Fatal>`. Left restores that iteration's checkpoint and stops if
the count satisfies the bounds; otherwise it reports insufficient successes.
Right propagates the fatal error. Previously successful iterations remain committed.
Arbitrary Either failures are not automatically assigned this meaning: callers
normalize their errors with mapFailure. Predicate iterator errors already distinguish
recognition on the left from source failure on the right, but a raw forward iterator
still needs a restoration implementation for general parser repetition.

Input must conform to Restorable with an Equatable checkpoint whose equality means
no cursor progress. Substring and ArraySlice have position-aware checkpoints in
swift-checkpoint. Custom scoped/noncopyable inputs can implement that contract.
External side effects of a parser are not rolled back. A zero-progress success
restores its input and throws; fatal failures retain the source's own consumption.

The concrete repeated parser borrows its stored operation and conditionally supports
Copyable. The current result collector returns an array and therefore requires
copyable, escapable outputs. This restriction does not apply to the separate direct
iterator delivery paths, which retain scoped/noncopyable element support.
Count-based collection selection still returns a slice without array allocation.

The `ClosedRange<Cardinal>.Parser` and corresponding partial/half-open range aliases
reuse Repetition.Parser. Ranges are not implicitly lifted as element consumption in
builders. The explicit input overload enables result-builder composition.

Legacy Iterator/Collection/Cursor parser packages and serializer redesign are not
migrated here. No automatic treatment of arbitrary parse failure as rejection is added.

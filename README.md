# swift-parser: mapping-property experiment

This uncommitted experiment changes mapping into source-bound, callable values:

```swift
let mapping = parser.map
let mapped = mapping { value in /* new output */ }

let binding = parser.flatMap
let chained = binding { value in /* next parser */ }

let remapped = parser.map.failure { error in /* new error */ }
```

`Map<Upstream>` and `FlatMap<Upstream>` hold the upstream. Their consuming
`callAsFunction` methods infer the result when the transform is supplied.
No MapScope or FlatMapScope type is introduced. The previous independent
transformations remain available as nested `Transform` values.

| Before | Experiment |
| --- | --- |
| `Map<Input, Output, Failure>` | `Map<Input>.Transform<Output, Failure>` |
| `Map<Input, Output, Failure>.Parser<Upstream>` | `Map<Upstream>.Parser<Output, Failure>` |
| `FlatMap<Input, Next>` | `FlatMap<Input>.Transform<Next>` |
| `FlatMap<Input, Next>.Parser<Upstream>` | `FlatMap<Upstream>.Parser<Next>` |
| `Map<OldError, NewError, Never>.Error.Parser<Upstream>` | `Map<Upstream>.Error.Parser<NewError>` |

`mapFailure` remains a forwarding convenience for `map.failure`. The optic
integration's existing labeled map overloads are moved onto `Map` as
`callAsFunction` overloads, retaining their typed failures.

## Compiler limitation: this is not ready to adopt

The experiment enables `UnderscoreOwned` and marks the properties `@_owned`
with `consuming get`. On the installed Apple Swift 6.4 compiler
(`swiftlang-6.4.0.33.1`):

1. A named noncopyable upstream needs `(consume upstream).map` or
   `(consume upstream).flatMap` to get past a compiler consumption diagnostic.
2. That workaround does **not** make ownership correct at runtime. The compiler
   releases a noncopyable value after handing it to the consuming getter. Its
   destructor runs before the new wrapper is discarded, then again when the
   wrapper is discarded. The package's destruction tests fail and the test
   process crashes when this also affects retained references.

A standalone reproduction is in
`Tests/Parser Tests/Fixtures/Owned Getter Destruction.swift`. It has no parser
or third-party dependencies. Run:

```sh
xcrun swiftc -swift-version 6 \
  -enable-experimental-feature UnderscoreOwned \
  'Tests/Parser Tests/Fixtures/Owned Getter Destruction.swift' \
  -o /tmp/owned-getter-destruction
/tmp/owned-getter-destruction
```

Expected destruction counts are 0 before discarding the wrapper and 1 after.
This compiler prints 1 and 2. Direct `Bound(consume owner)` construction gives
the correct 0 and 1. SIL inspection shows an extra `release_value` immediately
after the consuming getter call. Explicit transfer, transparent getters, and
optimized compilation did not correct the reproduced issue.

The source-bound design is implementable; this experimental property mechanism
is not yet reliable for the full ownership contract. A conservative alternative
would retain properties for copyable upstreams and consuming methods for
noncopyable upstreams. That alternative has not replaced this experiment.

## Validation

- Parser workspace build-for-testing: passed with the new property tests.
- Optic Parser workspace suite: 16 tests passed with the migrated overloads.
- Full Parser runtime suite: failed ownership assertions and crashed; it is not
  a passing test run. The added property tests retain the intended ownership
  assertions rather than accepting premature or duplicate destruction.
- Independent typed transformations, scoped-output restrictions, and
  noncopyable conformance checks remain represented in the existing tests.

The workspace command uses its resolved dependencies without updating branches:

```sh
xcodebuild \
  -workspace /Users/coen/Developer/coenttb/swift-institute/workspaces/parser.xcworkspace \
  -scheme 'Parser Tests' -destination 'platform=macOS' \
  -derivedDataPath /tmp/parser-map-investigation-build \
  -disableAutomaticPackageResolution -skipPackageUpdates build-for-testing
```

An unrestricted package update hit an unrelated dependency-identity conflict
between the swift-atoms and swift-molecules URLs. Keeping the workspace's
resolved dependencies allowed validation without changing mirrors or manifests'
dependency paths. No experiment changes have been committed or published.

## Restoring this branch with the optic integration

The matching optic changes are saved in
`Experiments/MappingProperties/optic-integration.patch`. The patch applies on top
of swift-optic-parser's pre-existing uncommitted method-adapter migration (the
state restored alongside main). Apply it from that repository with `git apply`
when revisiting this experiment. A separate optic branch could not be created
because writes to that repository's Git metadata were blocked. Its earlier
method-based source edits were preserved on main.

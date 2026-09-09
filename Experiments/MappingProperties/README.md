> Current implementation results supersede the early smoke tests below: see ../../README.md. Resource-owning noncopyable values expose premature and duplicate destruction through the experimental getter. Successful execution with trivial values did not establish correct ownership.

# Mapping-property investigation — Swift 6.4

Recommendation: keep the consuming `map`, `flatMap`, and `mapFailure` methods and the independent `Map<Source, Target, Failure>` / `FlatMap<Source, Continuation>` transformations with their nested `.Parser` adapters. The current API already provides `parser.map { ... }` and `parser.flatMap { ... }`, with correct inference and distinct semantics. I found no design that also gives genuine callable properties and `parser.map.failure { ... }` while preserving these concepts and avoiding a new operation-binding role.

This is an investigation against checkpoint `8268763`, not a production patch. All files here are isolated from package targets. The package's existing allowlist `.gitignore` ignores this directory; nothing was staged or committed. Existing staged gitlinks were preserved. A concurrent edit to `Sources/Parser/Parser.Witness.swift` appeared during the investigation and was left untouched; workspace test results describe the state at the time those tests ran.

## Why existing types cannot simply serve as properties

The property is obtained before the transform is supplied. Its receiver type must therefore depend only on the upstream parser. A generic `callAsFunction` can infer the new output, continuation, and thrown error later, but it needs a receiver that already owns the upstream and identifies which operation to perform.

Current `Map` owns a transformation; its target and failure are part of its type. Current `FlatMap` similarly knows its continuation. Neither owns an upstream parser until adapted. Their nested `.Parser` types inherit those outer generic arguments, even if a hypothetical nested declaration did not reference them. Swift 6.4 rejects a property declared as `Map.Parser<Self>` without specializing `Map`. It also rejects generic property declarations and the attempted universally generic function-value syntax. These are small compiler probes, not a claim that all conceivable syntax has been exhaustively tested.

`Map<Output, Output, Failure>.Parser<Self>` could only be constructed by supplying an identity transformation and error handling. It represents an actual identity parser rather than a pending operation, adds a parser layer unless optimized away, fixes arbitrary outer generic arguments, and requires `Output: Escapable` under the current adapter constraints. That would narrow the current fluent input-output support. An identity FlatMap is worse: upstream output must itself be a compatible parser and would be executed. Using `Never`/`Void` placeholders or metatype namespace keys avoids neither the semantic mismatch nor the fixed outer arguments. These alternatives were rejected by inspection, not benchmarked.

## Reusing Self: a compiling but unsuitable alternative

`self-property-alias.swift` adds consuming `var map: Self` and `var flatMap: Self`, plus a generic `failure` forwarding method on all parsers. It compiles alongside the actual methods and permits the desired three spellings for simple temporary receivers. It also handles noncopyable owners and scoped input/output in the tested cases.

However, trailing-closure calls still use the original methods. `let mapping = Source().map; mapping { ... }` fails because the property is only a parser. Both properties return exactly the same type and permit `.failure` directly and through `.flatMap`. Adding generic callable overloads to Self does not recover the selected operation: `self-reuse.swift` demonstrates that mapping a parser-valued output is then mistaken for flattening it, and flatMap accepts ordinary values. Runtime tags would require every conformer to carry new state or another wrapper.

The concrete alias expression `mapped.map.failure { ... }`, where `mapped` is a noncopyable `Map.Parser`, also fails SIL emission with a consumption diagnostic on this compiler. The fixture retains this as an expected rejection; I do not infer a general language restriction or precise compiler-bug cause from that diagnostic. Existing `Map.Parser` additionally already has a public `failure` closure, so this name is not a clean operation namespace.

## Related packages and possible redesign

Local `Either`, `Product`, and `Coproduct` use generic mapping methods. `Algebra.Magma` and its relatives wrap already-typed operations and make those callable; they do not provide an unbound generic transform through a property. This supports the present independent transformation representation.

`Sequence.Map<Base>` is the relevant property precedent: it stores Base, with generic callable methods producing nested eager/compact/flat computations. Adopting that design would mean changing Map into a source-bound family and moving the existing transformation and completed parser representation elsewhere. Calling the source holder `Map` rather than `MapScope` would still introduce the operation-binding role. This is coherent only if that broader conceptual/API migration is wanted for its own sake; it is not reuse of today's Map semantics.

`Operation.Application<Index>` is an existing ownership-aware input holder, but its `Symbol` fixes Input, Output, and Failure. It does not by itself express the later generic result of map. Distinguishing map/flatMap would still require meaningful symbols and callable adapters; specializing current transformation types with dummy arguments as keys would just hide the missing concept. `Witness` supplies a namespace/protocol and composition enum, not a compatible carrier. No swift-property dependency was introduced or needed for this finding.

## Evidence and reproduction

Compiler: Apple Swift 6.4 (`swiftlang-6.4.0.33.1`), arm64 macOS 27; Lifetimes and MoveOnlyTuples enabled for actual API probes.

- `sh run.sh`: three expected compiler rejections, plus a passing executable demonstrating the Self dispatch ambiguity.
- `sh run-workspace-probes.sh`: passing SIL emission against workspace-built modules for all three typed-error map cases, parser-valued map versus flatMap, independent transformation adapter inference, noncopyable outputs/continuations/owners, and scoped error-map passthrough. Stored-property invocation, double consumption, and the mapped-owner failure chain are rejected as recorded.
- The same script compiles the actual Optic Parser test source with the alias extension visible. All existing labeled optic overloads still compile. This is compilation, not a runtime test of a modified Parser library.
- Requested `parser.xcworkspace`, scheme `Parser Tests`: **95 tests passed**, including existing ownership and lifetime fixture tests.
- Same workspace, scheme `Optic Parser Tests`: **16 tests passed**.

Workspace tests use the unchanged production API. Other integration schemes were not run because no implementation was changed. The initial sandboxed Xcode attempt could not open the workspace; the approved ordinary Xcode run succeeded. Dependencies were resolved through the requested workspace, without mirrors or manifest/local-path substitutions.

Workspace command (repeat with the optic scheme):

```sh
xcodebuild -workspace /Users/coen/Developer/coenttb/swift-institute/workspaces/parser.xcworkspace \
  -scheme 'Parser Tests' -destination 'platform=macOS' \
  -derivedDataPath /tmp/parser-map-investigation-build test
```

The workspace probe script optionally accepts another Build/Products/Debug directory. Workspace logs are `/tmp/parser-map-workspace.log` and `/tmp/parser-map-optic.log`; xcresult bundles are under `/tmp/parser-map-investigation-build/Logs/Test`.

## Follow-up: a concrete source-bound redesign

**Correction after checking experimental features:** the noncopyable consuming getters work with `-enable-experimental-feature UnderscoreOwned` and `@_owned` on each property. `source-bound-redesign-owned.swift` compiles and runs successfully on the installed Swift 6.4 compiler. The restrictions recorded below describe the unannotated prototype, not a requirement to retain method fallbacks when this experimental feature is acceptable.

The initial recommendation was too categorical if read as ruling out redesign. `source-bound-redesign.swift` is a standalone, compiling and running implementation of `Map<Source>` and `FlatMap<Source>` with nested completed `.Parser` types and generic consuming `callAsFunction` methods. Stored properties retain the selected operation: a map can produce a noncopyable parser value while flatMap executes it. This prototype uses a fixed Int input, preserves typed failure for map, and erases flatMap failure to `any Error`; it demonstrates structure rather than a complete replacement for the production API.

With property extensions restricted to `Self: Copyable` it compiles and executes successfully. The otherwise analogous `source-bound-redesign-linear.swift` allows `Self: ~Copyable` and a noncopyable Source, but executable compilation rejects both consuming getters with `'self' is borrowed and cannot be consumed`. Thus a practical current-compiler implementation can use genuine properties for copyable upstreams plus consuming method fallbacks for noncopyable upstreams, as Sequence already does. A property-only API preserving all ownership capabilities is not established by this prototype.

Reproduction: `xcrun swiftc -swift-version 6 -module-cache-path /tmp/parser-map-probe-cache source-bound-redesign.swift -o /tmp/source-bound-redesign`, then run `/tmp/source-bound-redesign`. Compile the linear variant separately to reproduce the getter diagnostic.

Owned-property reproduction: `xcrun swiftc -swift-version 6 -enable-experimental-feature UnderscoreOwned -module-cache-path /tmp/parser-map-probe-cache source-bound-redesign-owned.swift -o /tmp/source-bound-redesign-owned`, then run `/tmp/source-bound-redesign-owned`. This removes the demonstrated noncopyable-upstream getter blocker; the full production typed-error and lifetime API remains to be validated.

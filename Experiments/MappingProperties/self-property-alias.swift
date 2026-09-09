import Parser
import Either

// An experiment only: the properties select no operation. Calls with a trailing
// closure still select the library's existing methods.
extension Parser.`Protocol` where Self: ~Copyable,
    Input: ~Copyable & ~Escapable, Output: ~Copyable & ~Escapable {
    var map: Self { consuming get { self } }
    var flatMap: Self { consuming get { self } }
    consuming func failure<E: Error>(_ transform: @escaping (Failure) -> E)
        -> Map<Failure, E, Never>.Error.Parser<Self> {
        mapFailure(transform)
    }
}

func aliases() {
    let _: Map<Value, Int, UpstreamError>.Parser<Source> = Source().map { $0.number }
    let _: FlatMap<Value, Next>.Parser<Source> = Source().flatMap { Next($0) }
    let _: Map<UpstreamError, TransformError, Never>.Error.Parser<Source> =
        Source().map.failure { _ in TransformError.failed }
    // These have exactly the same type; storing the property loses its name.
    let _: Source = Source().map
    let _: Source = Source().flatMap
    // The purported map-only operation is also available directly and on flatMap.
    let _ = Source().flatMap.failure { _ in TransformError.failed }
    let _ = Source().failure { _ in TransformError.failed }
}

struct ScopedInput: ~Copyable, ~Escapable {
    let values: Span<Int>
    @_lifetime(copy values)
    init(_ values: Span<Int>) { self.values = values }
}
struct ScopedOutput: ~Copyable, ~Escapable {
    let values: Span<Int>
    @_lifetime(copy values)
    init(_ values: Span<Int>) { self.values = values }
}
struct ScopedSource: ~Copyable, Parsing {
    @_lifetime(&input)
    func parse(_ input: inout ScopedInput) -> ScopedOutput {
        ScopedOutput(input.values)
    }
}
func scoped() {
    let values = [1, 2]
    var input = ScopedInput(values.span)
    let parser = ScopedSource().map.failure { (error: Never) in error }
    let result = parser.parse(&input)
    _ = result.values.count
}

#if CHAIN_FAILURE
func chainedFailure() {
    let mapped = Source().map { $0.number }
    // Map.Parser already stores a failure closure; check overload lookup too.
    let _ = mapped.map.failure { _ in TransformError.failed }
}
#endif

#if STORED_CALL
func storedCall() {
    let mapping = Source().map
    let _ = mapping { $0.number }
}
#endif
#if DOUBLE_CONSUME
func doubleConsume() {
    let source = Source()
    let a = source.map
    let b = source.flatMap
    _ = consume a
    _ = consume b
}
#endif

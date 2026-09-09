import Parser
import Either

enum UpstreamError: Error { case failed }
enum TransformError: Error { case failed }
struct Value: ~Copyable { let number: Int }
struct Source: ~Copyable, Parsing {
    func parse(_ input: inout Int) throws(UpstreamError) -> Value {
        Value(number: input)
    }
}
struct Pure: ~Copyable, Parsing {
    func parse(_ input: inout Int) -> Value { Value(number: input) }
}
struct Next: ~Copyable, Parsing {
    let value: Value
    init(_ value: consuming Value) { self.value = value }
    func parse(_ input: inout Int) throws(TransformError) -> Int { value.number }
}

func infer() {
    let _: Map<Value, Int, UpstreamError>.Parser<Source> = Source().map { $0.number }
    let _: Map<Value, Int, Either<UpstreamError, TransformError>>.Parser<Source> =
        Source().map { (value: consuming Value) throws(TransformError) in value.number }
    let _: Map<Value, Int, TransformError>.Parser<Pure> =
        Pure().map { (value: consuming Value) throws(TransformError) in value.number }
    // Mapping a parser value and flattening it must remain different operations.
    let _: Map<Value, Next, UpstreamError>.Parser<Source> = Source().map { Next($0) }
    let _: FlatMap<Value, Next>.Parser<Source> = Source().flatMap { Next($0) }
    let _: Map<UpstreamError, TransformError, Never>.Error.Parser<Source> =
        Source().mapFailure { _ in TransformError.failed }
    let transform = Map { (value: consuming Value) in value.number }
    let _: Map<Value, Int, Never>.Parser<Pure> = transform.parser(Pure())
    let continuation = FlatMap { (value: consuming Value) in Next(value) }
    let _: FlatMap<Value, Next>.Parser<Source> = continuation.parser(Source())
}

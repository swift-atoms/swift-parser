protocol Parsing: ~Copyable {
    associatedtype Output: ~Copyable
    associatedtype Failure: Error
    borrowing func parse(_ input: inout Int) throws(Failure) -> Output
}
struct Map<Source: ~Copyable>: ~Copyable {
    let source: Source
    init(_ source: consuming Source) { self.source = source }
}
struct FlatMap<Source: ~Copyable>: ~Copyable {
    let source: Source
    init(_ source: consuming Source) { self.source = source }
}
extension Map where Source: Parsing & ~Copyable {
    struct Parser<Target: ~Copyable>: Parsing, ~Copyable {
        let upstream: Source
        let transform: (consuming Source.Output) -> Target
        borrowing func parse(_ input: inout Int) throws(Source.Failure) -> Target {
            transform(try upstream.parse(&input))
        }
    }
    consuming func callAsFunction<Target: ~Copyable>(
        _ transform: @escaping (consuming Source.Output) -> Target
    ) -> Parser<Target> {
        Parser(upstream: source, transform: transform)
    }
}
extension FlatMap where Source: Parsing & ~Copyable {
    struct Parser<Next: Parsing & ~Copyable>: Parsing, ~Copyable {
        let upstream: Source
        let transform: (consuming Source.Output) -> Next
        borrowing func parse(_ input: inout Int) throws -> Next.Output {
            let next = transform(try upstream.parse(&input))
            return try next.parse(&input)
        }
    }
    consuming func callAsFunction<Next: Parsing & ~Copyable>(
        _ transform: @escaping (consuming Source.Output) -> Next
    ) -> Parser<Next> {
        Parser(upstream: source, transform: transform)
    }
}
extension Map: Copyable where Source: Copyable {}
extension FlatMap: Copyable where Source: Copyable {}
extension Parsing where Self: ~Copyable {
    @_owned var map: Map<Self> { consuming get { Map(consume self) } }
    @_owned var flatMap: FlatMap<Self> { consuming get { FlatMap(consume self) } }
}
struct Source: Parsing, ~Copyable {
    func parse(_ input: inout Int) -> Int { input }
}
struct Next: Parsing, ~Copyable {
    let value: Int
    func parse(_ input: inout Int) -> Int { value + 10 }
}
func exercise() throws {
    let m = Source().map
    let mapped = m { Next(value: $0) }
    let f = Source().flatMap
    let flattened = f { Next(value: $0) }
    var input = 2
    let value: Next = mapped.parse(&input)
    let number: Int = try flattened.parse(&input)
    assert(value.value == 2 && number == 12)
}
try exercise()
print("Source-bound properties compile and execute with distinct map/flatMap semantics")

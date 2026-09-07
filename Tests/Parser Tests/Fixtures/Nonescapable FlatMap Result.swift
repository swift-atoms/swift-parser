import Parser

struct ScopedResult: ~Copyable, ~Escapable {
    let number: Int
}

struct Source: Parser.`Protocol` {
    borrowing func parse(_ input: inout Int) -> Int { input }
}

struct Destination: Parser.`Protocol` {
    @_lifetime(&input)
    borrowing func parse(_ input: inout Int) -> ScopedResult {
        ScopedResult(number: input)
    }
}

func rejectScopedDownstreamResults() {
    _ = Parser.FlatMap(upstream: Source()) { _ in Destination() }
    _ = Source().flatMap { _ in Destination() }
}

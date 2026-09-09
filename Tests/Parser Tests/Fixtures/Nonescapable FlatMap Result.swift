import Parser

struct ScopedResult: ~Copyable, ~Escapable {
    let number: Int
}

struct Source: Parsing {
    borrowing func parse(_ input: inout Int) -> Int { input }
}

struct Destination: Parsing {
    @_lifetime(&input)
    borrowing func parse(_ input: inout Int) -> ScopedResult {
        ScopedResult(number: input)
    }
}

func rejectScopedDownstreamResults() {
    _ = Parser::FlatMap.Parser(upstream: Source()) { _ in Destination() }
    _ = Source().flatMap { _ in Destination() }
}

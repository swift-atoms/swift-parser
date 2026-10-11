import FlatMap
import Parser

struct ScopedResult: ~Copyable, ~Escapable {
    let number: Int
}

struct Source: Parsing {
}

extension Source {
    borrowing func parse(_ input: inout Int) -> Int { input }
}

struct Destination: Parsing {
}

extension Destination {
    @_lifetime(&input)
    borrowing func parse(_ input: inout Int) -> ScopedResult {
        ScopedResult(number: input)
    }
}

func rejectScopedDownstreamResults() {
    _ = FlatMap::FlatMap.Parser(upstream: Source()) { _ in Destination() }
    _ = Source().flatMap { _ in Destination() }
}

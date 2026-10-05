import FlatMap
import Parser

struct ScopedResult: ~Copyable, ~Escapable {
    let number: Int
}

struct Source: Parsing {
    var body: Never {
        borrowing get { return fatalError() }
    }
    borrowing func parse(_ input: inout Int) -> Int { input }
}

struct Destination: Parsing {
    var body: Never {
        borrowing get { return fatalError() }
    }
    @_lifetime(&input)
    borrowing func parse(_ input: inout Int) -> ScopedResult {
        ScopedResult(number: input)
    }
}

func rejectScopedDownstreamResults() {
    _ = FlatMap::FlatMap.Parser(upstream: Source()) { _ in Destination() }
    _ = Source().flatMap { _ in Destination() }
}

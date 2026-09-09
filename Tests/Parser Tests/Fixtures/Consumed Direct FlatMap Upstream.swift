import Parser

struct Owned: ~Copyable, Parser.`Protocol` {
    borrowing func parse(_ input: inout Int) -> Int { input }
}

func reuseConsumedUpstream() throws {
    let upstream = Owned()
    let mapped = Parser::FlatMap.Parser(upstream: upstream) { _ in Owned() }
    var input = 0
    _ = upstream.parse(&input)
    _ = try mapped.parse(&input)
}

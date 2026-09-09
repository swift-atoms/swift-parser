import Parser

struct Cursor: ~Copyable, ~Escapable {
    let values: Span<Int>
    @_lifetime(copy values)
    init(_ values: Span<Int>) { self.values = values }
}

@Builder<Cursor>
func branch(_ left: Bool) -> Either<Parser<Cursor, Span<Int>, Never>, Parser<Cursor, Span<Int>, Never>>.Parser {
    if left { Parser<Cursor, Span<Int>, Never> { $0.values } }
    else { Parser<Cursor, Span<Int>, Never> { $0.values } }
}

func scopedResult() throws {
    let values = [1, 2]
    var input = Cursor(values.span)
    let parser = branch(true)
    let output = try parser.parse(&input)
    _ = output.count
}

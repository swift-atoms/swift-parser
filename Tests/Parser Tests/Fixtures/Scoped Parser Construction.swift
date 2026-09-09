import Parser

struct Cursor: ~Copyable, ~Escapable {
    let values: Span<Int>
    @_lifetime(copy values)
    init(_ values: Span<Int>) { self.values = values }
}

func directScopedResult() {
    let parser = Parser<Cursor, Span<Int>, Never> { input in input.values }
    let values = [1, 2]
    var input = Cursor(values.span)
    let output = parser.parse(&input)
    _ = output.count
}

func builderScopedInput() {
    let parser = Parser {
        Parser<Cursor, Int, Never> { input in input.values.count }
    }
    let values = [1, 2]
    var input = Cursor(values.span)
    _ = parser.parse(&input)
}

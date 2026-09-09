import Parser

func escapingResult() throws -> Span<Int> {
    let values = [1, 2]
    var input = values.span
    let selected: Either<Parser<Span<Int>, Span<Int>, Never>, Parser<Span<Int>, Span<Int>, Never>> = .left(Parser { $0 })
    let parser = selected.parser()
    return try parser.parse(&input)
}

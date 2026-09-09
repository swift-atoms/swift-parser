import Parser

@_lifetime(borrow parser)
func escape(_ parser: borrowing Parser<[Int], Span<Int>, Never>) -> Span<Int> {
    var input = [1, 2]
    return parser.parse(&input)
}

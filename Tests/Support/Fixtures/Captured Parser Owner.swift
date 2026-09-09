import Parser

struct Linear: ~Copyable, Parsing {
    borrowing func parse(_ input: inout Int) -> Int {
        input += 1
        return input
    }
}

func probe() {
    let owner = Linear()
    let parser = Parser::Parser {
        consume owner
    }
    var input = 0
    _ = parser.parse(&input)
}

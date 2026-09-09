import Parser

struct Owned: Parsing, ~Copyable {
    borrowing func parse(_ input: inout Int) -> Int { input }
}

func invalidReuse() {
    let owner = Owned()
    let parser = owner.mapFailure { (error: Never) in error }
    var input = 0
    _ = owner.parse(&input)
    _ = parser.parse(&input)
}

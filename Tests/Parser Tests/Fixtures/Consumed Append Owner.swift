import Parser

struct Linear: ~Copyable, Parsing {
    borrowing func parse(_ input: inout Int) -> Int {
        input += 1
        return input
    }
}

func probe() {
    let owner = Linear()
    let parser = Builder<Int>.buildPartialBlock(accumulated: owner, next: Linear())
    var input = 0
    _ = owner.parse(&input)
    _ = parser.parse(&input)
}

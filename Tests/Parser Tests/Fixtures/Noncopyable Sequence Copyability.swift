import Parser

struct Linear: ~Copyable, Parser.`Protocol` {
    borrowing func parse(_ input: inout Int) -> Int {
        input += 1
        return input
    }
}

func requireCopyable<T: Copyable>(_ value: T) {}

func probe() {
    let parser = Parser.Sequence(Int.self) { Linear() }
    requireCopyable(parser)
}

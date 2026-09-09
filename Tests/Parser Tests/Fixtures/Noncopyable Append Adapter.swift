import Parser

struct Linear: Parsing, ~Copyable {
    borrowing func parse(_ input: inout Int) -> Int { input }
}

func requireCopyable<T: Copyable>(_ value: T) {}

func invalidCopy() {
    let append = Append<Int, Int, Int, Never> { $0 + $1 }
    let parser = append.parser(Linear(), Linear())
    requireCopyable(parser)
}

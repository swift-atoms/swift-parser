import Map
import Parser

struct Owned: Parsing, ~Copyable {
    borrowing func parse(_ input: inout Int) -> Int { input }
}

func requireCopyable<T: Copyable>(_ value: T) {}

func invalidCopy() {
    let parser = Owned().mapFailure { (error: Never) in error }
    requireCopyable(parser)
}

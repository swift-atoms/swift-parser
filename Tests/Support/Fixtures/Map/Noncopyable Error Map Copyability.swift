import Map
import Parser

struct Owned: Parsing, ~Copyable {
    var body: Never {
        borrowing get { return fatalError() }
    }
    borrowing func parse(_ input: inout Int) -> Int { input }
}

func requireCopyable<T: Copyable>(_ value: T) {}

func invalidCopy() {
    let parser = Owned().mapFailure { (error: Never) in error }
    requireCopyable(parser)
}

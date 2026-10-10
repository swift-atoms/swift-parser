import FlatMap
import Parser

struct Owned: ~Copyable, Parsing {
    var body: Never {
        borrowing get { return fatalError() }
    }
    borrowing func parse(_ input: inout Int) -> Int { input }
}

func requireCopyable<T: Copyable>(_: T) {}

func rejectCopyingTheStoredOwner() {
    let mapped = Owned().flatMap { _ in Owned() }
    requireCopyable(mapped)
}

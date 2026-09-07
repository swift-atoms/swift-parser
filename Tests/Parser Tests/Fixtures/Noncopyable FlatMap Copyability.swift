import Parser

struct Owned: ~Copyable, Parser.`Protocol` {
    borrowing func parse(_ input: inout Int) -> Int { input }
}

func requireCopyable<T: Copyable>(_: T) {}

func rejectCopyingTheStoredOwner() {
    let mapped = Owned().flatMap { _ in Owned() }
    requireCopyable(mapped)
}

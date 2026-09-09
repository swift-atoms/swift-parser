import Parser

struct ScopedResult: ~Copyable, ~Escapable {
    let value: Int
}

struct Source: Parsing {
    typealias Input = Int
    typealias Output = Int
    typealias Failure = Never

    borrowing func parse(_ input: inout Int) -> Int {
        input
    }
}

func proveStoredTransformCannotReturnNonescapableResult() {
    _ = Source().map { (value: consuming Int) -> ScopedResult in
        ScopedResult(value: value)
    }
}

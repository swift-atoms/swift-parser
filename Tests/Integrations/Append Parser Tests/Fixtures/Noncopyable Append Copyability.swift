import Append
import Parser

struct Linear: ~Copyable, Parsing {
    borrowing func parse(_ input: inout Int) -> Int {
        input += 1
        return input
    }
}

func requireCopyable<T: Copyable>(_ value: T) {}

func probe() {
    let parser = Builder<Int>.buildPartialBlock(accumulated: Linear(), next: Linear())
    requireCopyable(parser)
}

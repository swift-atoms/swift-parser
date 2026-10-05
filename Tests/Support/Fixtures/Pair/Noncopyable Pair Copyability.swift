import Parser
import Pair

struct Linear: ~Copyable, Parsing {
    var body: Never {
        borrowing get { return fatalError() }
    }
    borrowing func parse(_ input: inout Int) -> Int {
        input += 1
        return input
    }
}

func requireCopyable<T: Copyable>(_ value: T) {}

func probe() {
    let parser = Pair(Linear(), Linear()).parser()
    requireCopyable(parser)
}

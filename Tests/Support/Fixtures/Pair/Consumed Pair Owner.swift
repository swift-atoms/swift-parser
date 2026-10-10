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

func probe() {
    let owners = Pair(Linear(), Linear())
    let parser = owners.parser()
    var input = 0
    _ = owners.first.parse(&input)
    _ = parser.parse(&input)
}

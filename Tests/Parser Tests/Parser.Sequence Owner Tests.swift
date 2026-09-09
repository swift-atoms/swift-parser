import Parser
import Testing

@Suite
struct `Parser bodies preserve noncopyable stored owners` {

    @Test
    func `default body forwarding borrows a stored noncopyable owner`() throws {
        let lifetime = Lifetime()
        let parser = BodyOwner(lifetime)
        var input = 0

        #expect(try parser.parse(&input) == 1)
        #expect(try parser.parse(&input) == 2)
        #expect(lifetime.destroyed == 0)

        discard(parser)

        #expect(lifetime.destroyed == 1)
    }
}

private final class Lifetime {
    var destroyed = 0
}

private struct Value: ~Copyable, Parsing {
    enum Error: Swift.Error { case rejected }

    let lifetime: Lifetime

    deinit { lifetime.destroyed += 1 }

    borrowing func parse(_ input: inout Int) throws(Error) -> Int {
        input += 1
        return input
    }
}

private struct BodyOwner: ~Copyable, Parsing {
    typealias Failure = Value.Error

    let body: Value

    init(_ lifetime: Lifetime) {
        body = Value(lifetime: lifetime)
    }
}

private func discard<T: ~Copyable>(_ value: consuming T) {}

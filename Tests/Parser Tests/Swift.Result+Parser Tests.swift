import Parser
import Testing

@Suite
struct `Swift.Result+Parser Tests` {
    @Test
    func `a result borrows its noncopyable parser for repeated parses`() {
        let parser = Swift.Result<Owner, Never>.Parser(.success(Owner()))
        var input = 0
        let first = parser.parse(&input)
        let second = parser.parse(&input)
        #expect(first.value == 1)
        #expect(second.value == 2)
    }

    @Test
    func `a successful result runs its parser through a body`() throws {
        var input = 4
        #expect(try Selected(available: true).parse(&input) == 4)
        #expect(input == 5)
    }

    @Test
    func `a failed result throws without consuming input`() {
        var input = 4
        #expect(throws: Rejected.unavailable) {
            try Selected(available: false).parse(&input)
        }
        #expect(input == 4)
    }

    @Test
    func `a successful result preserves its parsers failure`() {
        var input = -1
        #expect(throws: Rejected.negative) {
            try Selected(available: true).parse(&input)
        }
        #expect(input == -1)
    }

    @Test
    func `a result expression works in a Parser construction block`() throws {
        let parser = Parser<Int, Int, Rejected> {
            Result<Next, Rejected>.success(Next())
        }
        var input = 4
        #expect(try parser.parse(&input) == 4)
        #expect(input == 5)
    }
}

private enum Rejected: Error, Equatable { case unavailable, negative }

private struct Next: Parsing {
    typealias Failure = Rejected

    var body: some Parsing<Int, Int, Rejected> {
        Parser<Int, Int, Rejected> { input throws(Rejected) in
            guard input >= 0 else { throw .negative }
            defer { input += 1 }
            return input
        }
    }
}

private struct Selected: Parsing {
    typealias Failure = Rejected
    let available: Bool

    var body: some Parsing<Int, Int, Rejected> {
        available ? Result<Next, Rejected>.success(Next()) : .failure(.unavailable)
    }
}

private struct Value: ~Copyable { let value: Int }

private struct Owner: Parsing, ~Copyable {
    borrowing func parse(_ input: inout Int) -> Value {
        input += 1
        return Value(value: input)
    }
}

import Either
import Parser
import Testing

@Suite
struct `Parser supports function and builder construction` {
    @Test
    func `builder infers channels and runs once`() {
        let count = Count()
        let parser = Parser {
            count.build()
            Parser<Int, Void, Never> { $0 += 1 }
        }
        requireParsing(parser)
        var input = 3
        #expect(parser.parse(&input) == 3)
        #expect(parser.parse(&input) == 5)
        #expect(input == 7)
        #expect(count.builds == 1)
    }

    @Test
    func `explicit channels accept a builder and preserve typed failure`() {
        let parser = Parser<Int, Int, Rejected> {
            Parser<Int, Int, Rejected> { input throws(Rejected) in
                input += 1
                throw .invalid
            }
        }
        var input = 0
        do throws(Rejected) {
            _ = try parser.parse(&input)
            Issue.record("Expected rejection")
        } catch {
            #expect(error == .invalid)
        }
        #expect(input == 1)
    }

    @Test
    func `builder retains a noncopyable owner and produces noncopyable outputs`() {
        let count = Count()
        do {
            let parser = Parser { Owner(count: count) }
            var input = 0
            let first = parser.parse(&input)
            let second = parser.parse(&input)
            #expect(first.value == 1)
            #expect(second.value == 2)
            #expect(count.destroyed == 0)
        }
        #expect(count.destroyed == 1)
    }

    @Test
    func `direct construction produces noncopyable outputs`() {
        let parser = Parser<Int, Value, Never> { Value(value: $0) }
        var input = 42
        let result = parser.parse(&input)
        #expect(result.value == 42)
    }
}

private func requireParsing<P: Parsing>(_ parser: P)
where P.Input == Int, P.Output == Int, P.Failure == Never {}

private enum Rejected: Error { case invalid }
private struct Value: ~Copyable { let value: Int }
private final class Count {
    var builds = 0
    var destroyed = 0
    func build() -> Parser<Int, Int, Never> {
        builds += 1
        return Parser { input in
            let result = input
            input += 1
            return result
        }
    }
}
private struct Owner: Parsing, ~Copyable {
    let count: Count
    borrowing func parse(_ input: inout Int) -> Value {
        input += 1
        return Value(value: input)
    }
    deinit { count.destroyed += 1 }
}

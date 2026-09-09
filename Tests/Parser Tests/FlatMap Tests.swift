import Parser
import Testing

@Suite
struct `FlatMap selects continuations independently of parsing` {

    @Test
    func `a factory can return a noncopyable continuation`() {
        let flatMap = Parser::FlatMap<Int, Continuation> { Continuation(value: $0) }
        let continuation = flatMap(42)
        #expect(continuation.value == 42)
    }

    @Test
    func `an instance adapts its selected parser`() throws {
        let flatMap = Parser::FlatMap<Int, Parser<Int, Int, Never>> { seed in
            Parser { input in
                input += 1
                return seed + input
            }
        }
        let parser = flatMap.parser(Parser<Int, Int, Never> { input in
            input += 1
            return input
        })
        var input = 0
        #expect(try parser.parse(&input) == 3)
        #expect(input == 2)
    }

    private struct Continuation: ~Copyable {
        let value: Int
    }
}

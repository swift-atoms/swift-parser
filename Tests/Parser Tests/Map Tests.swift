import Parser
import Testing

@Suite
struct `Map values and parser adapters` {

    @Test
    func `a standalone map preserves typed failure`() {
        let map = Parser::Map<Int, String, Rejected> { value throws(Rejected) in
            guard value >= 0 else { throw .negative }
            return String(value)
        }
        do throws(Rejected) {
            #expect(try map(42) == "42")
            _ = try map(-1)
            Issue.record("Expected rejection")
        } catch {
            #expect(error == .negative)
        }
    }

    @Test
    func `a standalone map carries a scoped result`() {
        let map = Parser::Map<Span<Int>, Span<Int>, Never> {
            (source: consuming Span<Int>) in source
        }
        let values = [10, 20]
        let result = map(values.span)
        #expect(result[0] == 10)
        #expect(result[1] == 20)
    }

    @Test
    func `the same transformation can be used directly and as a parser`() {
        let map = Parser::Map<Int, String, Never> { String($0) }
        let parser = map.parser(Parser.Pure<Int, Int> { input in
            input += 1
            return input
        })
        var input = 41
        #expect(map(42) == "42")
        #expect(parser.parse(&input) == "42")
        #expect(input == 42)
    }

    private enum Rejected: Swift.Error { case negative }
}

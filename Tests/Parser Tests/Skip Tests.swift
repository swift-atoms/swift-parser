import Parser
import Testing

@Suite
struct `Skip discards values independently of parsing` {

    @Test
    func `a scoped value is retained and a linear value is destroyed`() {
        let lifetime = Lifetime()
        let skip = Parser::Skip<Span<Int>, Token>()
        let values = [42]
        let result = skip(values.span, Token(lifetime: lifetime))
        #expect(result[0] == 42)
        #expect(lifetime.destroyed == 1)
    }

    @Test
    func `its adapter executes both parsers and discards the second result`() {
        let skip = Parser::Skip<Int, Int>()
        let number = Parser<Int, Int, Never> { input in
            input += 1
            return input
        }
        let parser = skip.parser(number, number)
        var input = 0
        #expect(parser.parse(&input) == 1)
        #expect(input == 2)
    }

    private final class Lifetime { var destroyed = 0 }
    private struct Token: ~Copyable {
        let lifetime: Lifetime
        deinit { lifetime.destroyed += 1 }
    }
}

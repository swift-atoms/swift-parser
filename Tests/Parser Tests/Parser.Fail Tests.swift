import Parser
import Testing

@Suite
struct `Parser.Fail` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

extension `Parser.Fail`.Unit {
    @Test
    func `always throws the provided error`() {
        let parser = Parser.Fail<Parser.Test.Input, Int, Parser.Match.Error>(
            .predicateFailed(description: "test error")
        )
        var input = Parser.Test.Input([0x01, 0x02])

        #expect(throws: Parser.Match.Error.self) {
            try parser.parse(&input)
        }
    }
}

extension `Parser.Fail`.`Edge Case` {
    @Test
    func `throws on empty input without consuming`() {
        let parser = Parser.Fail<Parser.Test.Input, Void, Parser.Constraint.Error>(
            .countTooLow(expected: 1, got: 0)
        )
        var input = Parser.Test.Input([])

        #expect(throws: Parser.Constraint.Error.self) {
            try parser.parse(&input)
        }
    }
}

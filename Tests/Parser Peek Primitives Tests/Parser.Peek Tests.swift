import Parser_Primitives_Test_Support
import Testing

@Suite
struct `Parser.Peek` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

extension `Parser.Peek`.Unit {
    @Test
    func `returns output without consuming input`() throws(any Swift.Error) {
        let parser = Parser.First.Element<Parser.Test.Input>().peek()
        var input = Parser.Test.Input([0x41, 0x42])

        let result = try parser.parse(&input)

        #expect(result == 0x41)
        #expect(input.first == 0x41)
    }

    @Test
    func `repeated peeks return same value`() throws(any Swift.Error) {
        let parser = Parser.First.Element<Parser.Test.Input>().peek()
        var input = Parser.Test.Input([0xFF])

        let first = try parser.parse(&input)
        let second = try parser.parse(&input)

        #expect(first == second)
        #expect(first == 0xFF)
    }
}

extension `Parser.Peek`.`Edge Case` {
    @Test
    func `upstream failure does not consume input`() {
        let parser = Parser.First.Where<Parser.Test.Input> { $0 == 0x41 }.peek()
        var input = Parser.Test.Input([0x42])

        #expect(throws: (any Swift.Error).self) {
            try parser.parse(&input)
        }
        #expect(input.first == 0x42)
    }

    @Test
    func `empty input propagates upstream error`() {
        let parser = Parser.First.Element<Parser.Test.Input>().peek()
        var input = Parser.Test.Input([])

        #expect(throws: Parser.EndOfInput.Error.self) {
            try parser.parse(&input)
        }
    }
}

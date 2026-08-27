import Parser
import Testing

@Suite
struct `Parser.Rest` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

extension `Parser.Rest`.Unit {
    @Test
    func `consumes all remaining input`() {
        let parser = Parser.Rest<Parser.Test.Input>()
        var input: Parser.Test.Input = [0x01, 0x02, 0x03]

        let result = parser.parse(&input)

        #expect(result == [0x01, 0x02, 0x03])
        #expect(input.isEmpty)
    }
}

extension `Parser.Rest`.`Edge Case` {
    @Test
    func `returns empty slice on empty input`() {
        let parser = Parser.Rest<Parser.Test.Input>()
        var input: Parser.Test.Input = []

        let result = parser.parse(&input)

        #expect(result.isEmpty)
        #expect(input.isEmpty)
    }

    @Test
    func `returns single element`() {
        let parser = Parser.Rest<Parser.Test.Input>()
        var input: Parser.Test.Input = [0xFF]

        let result = parser.parse(&input)

        #expect(result == [0xFF])
    }
}

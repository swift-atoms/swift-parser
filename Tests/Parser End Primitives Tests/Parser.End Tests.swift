import Parser_Primitives_Test_Support
import Testing

@Suite
struct `Parser.End` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

extension `Parser.End`.Unit {
    @Test
    func `succeeds on empty input`() throws(any Swift.Error) {
        let parser = Parser.End<Parser.Test.Input>()
        var input: Parser.Test.Input = []

        try parser.parse(&input)
    }
}

extension `Parser.End`.`Edge Case` {
    @Test
    func `fails with remaining input`() {
        let parser = Parser.End<Parser.Test.Input>()
        var input: Parser.Test.Input = [0x01, 0x02]

        #expect(throws: Parser.Match.Error.self) {
            try parser.parse(&input)
        }
    }

    @Test
    func `fails with single remaining byte`() {
        let parser = Parser.End<Parser.Test.Input>()
        var input: Parser.Test.Input = [0xFF]

        #expect(throws: Parser.Match.Error.self) {
            try parser.parse(&input)
        }
    }
}

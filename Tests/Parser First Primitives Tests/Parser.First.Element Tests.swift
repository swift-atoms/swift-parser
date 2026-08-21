import Parser_Primitives_Test_Support
import Testing

@Suite
struct `Parser.First.Element` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

extension `Parser.First.Element`.Unit {
    @Test
    func `returns first element and advances`() throws(any Swift.Error) {
        let parser = Parser.First.Element<Parser.Test.Input>()
        var input = Parser.Test.Input([0x41, 0x42, 0x43])

        let result = try parser.parse(&input)

        #expect(result == 0x41)
        #expect(input.first == 0x42)
    }

    @Test
    func `consumes last element leaving input empty`() throws(any Swift.Error) {
        let parser = Parser.First.Element<Parser.Test.Input>()
        var input = Parser.Test.Input([0xFF])

        let result = try parser.parse(&input)

        #expect(result == 0xFF)
        #expect(input.isEmpty)
    }
}

extension `Parser.First.Element`.`Edge Case` {
    @Test
    func `fails on empty input`() {
        let parser = Parser.First.Element<Parser.Test.Input>()
        var input = Parser.Test.Input([])

        #expect(throws: Parser.EndOfInput.Error.self) {
            try parser.parse(&input)
        }
    }
}

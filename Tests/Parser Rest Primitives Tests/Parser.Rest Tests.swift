import Parser_Primitives_Test_Support
import Testing

// MARK: - Test Suite Structure

@Suite
struct `Parser.Rest` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

// MARK: - Unit Tests

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

// MARK: - Edge Case Tests

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

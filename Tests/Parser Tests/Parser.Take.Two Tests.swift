import Parser
import Testing

@Suite
struct `Parser.Take.Two` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

extension `Parser.Take.Two`.Unit {
    @Test
    func `runs both parsers and collects outputs`() throws(any Swift.Error) {
        let parser = Parser.Take.Two(
            Parser.First.Element<Parser.Test.Input>(),
            Parser.First.Element<Parser.Test.Input>()
        )
        var input = Parser.Test.Input([0x0A, 0x0B, 0x0C])

        let (first, second) = try parser.parse(&input)

        #expect(first == 0x0A)
        #expect(second == 0x0B)
        #expect(input.first == 0x0C)
    }

    @Test
    func `map transforms tuple output`() throws(any Swift.Error) {
        let parser = Parser.Take.Two(
            Parser.First.Element<Parser.Test.Input>(),
            Parser.First.Element<Parser.Test.Input>()
        ).map { a, b in Int(a) + Int(b) }
        var input = Parser.Test.Input([0x01, 0x02])

        let result = try parser.parse(&input)

        #expect(result == 3)
    }
}

extension `Parser.Take.Two`.`Edge Case` {
    @Test
    func `fails when first parser fails`() {
        let parser = Parser.Take.Two(
            Parser.First.Element<Parser.Test.Input>(),
            Parser.First.Element<Parser.Test.Input>()
        )
        var input = Parser.Test.Input([])

        #expect(throws: (any Swift.Error).self) {
            try parser.parse(&input)
        }
    }

    @Test
    func `fails when second parser fails after first succeeds`() {
        let parser = Parser.Take.Two(
            Parser.First.Element<Parser.Test.Input>(),
            Parser.First.Element<Parser.Test.Input>()
        )
        var input = Parser.Test.Input([0x01])

        #expect(throws: (any Swift.Error).self) {
            try parser.parse(&input)
        }
    }
}

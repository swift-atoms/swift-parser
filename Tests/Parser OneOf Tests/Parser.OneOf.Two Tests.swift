import Parser_Test_Support
import Testing

@Suite
struct `Parser.OneOf.Two` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

extension `Parser.OneOf.Two`.Unit {
    @Test
    func `returns first parser result when it succeeds`() throws(any Swift.Error) {
        let parser = Parser.OneOf.Two(
            Parser.First.Where<Parser.Test.Input> { $0 == 0x41 }.map { _ in "A" },
            Parser.First.Where<Parser.Test.Input> { $0 == 0x42 }.map { _ in "B" }
        )
        var input = Parser.Test.Input([0x41])

        let result = try parser.parse(&input)

        #expect(result == "A")
    }

    @Test
    func `falls back to second parser when first fails`() throws(any Swift.Error) {
        let parser = Parser.OneOf.Two(
            Parser.First.Where<Parser.Test.Input> { $0 == 0x41 }.map { _ in "A" },
            Parser.First.Where<Parser.Test.Input> { $0 == 0x42 }.map { _ in "B" }
        )
        var input = Parser.Test.Input([0x42])

        let result = try parser.parse(&input)

        #expect(result == "B")
    }
}

extension `Parser.OneOf.Two`.`Edge Case` {
    @Test
    func `fails when both alternatives fail`() {
        let parser = Parser.OneOf.Two(
            Parser.First.Where<Parser.Test.Input> { $0 == 0x41 },
            Parser.First.Where<Parser.Test.Input> { $0 == 0x42 }
        )
        var input = Parser.Test.Input([0x43])

        #expect(throws: (any Swift.Error).self) {
            try parser.parse(&input)
        }
    }

    @Test
    func `backtracks first attempt before trying second`() throws(any Swift.Error) {
        let parser = Parser.OneOf.Two(
            Parser.First.Where<Parser.Test.Input> { $0 == 0xFF }.map { _ in "first" },
            Parser.First.Element<Parser.Test.Input>().map { _ in "second" }
        )
        var input = Parser.Test.Input([0x42])

        let result = try parser.parse(&input)

        #expect(result == "second")
        #expect(input.isEmpty)
    }
}

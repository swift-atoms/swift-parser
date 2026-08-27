import Parser
import Testing

@Suite
struct `Parser.Prefix.UpTo` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

extension `Parser.Prefix.UpTo`.Unit {
    @Test
    func `consumes up to delimiter without including it`() {
        let parser = Parser.Prefix.UpTo<Parser.Test.Input>([UInt8(ascii: ",")])
        var input = Parser.Test.Input(utf8: "hello,world")

        let result = parser.parse(&input)

        #expect(result == Parser.Test.Input(utf8: "hello"))
        #expect(input.first == UInt8(ascii: ","))
    }

    @Test
    func `handles multi-byte delimiter`() {
        let parser = Parser.Prefix.UpTo<Parser.Test.Input>(Swift.Array("-->".utf8))
        var input = Parser.Test.Input(utf8: "content-->rest")

        let result = parser.parse(&input)

        #expect(result == Parser.Test.Input(utf8: "content"))
    }
}

extension `Parser.Prefix.UpTo`.`Edge Case` {
    @Test
    func `consumes all when delimiter not found`() {
        let parser = Parser.Prefix.UpTo<Parser.Test.Input>([0xFF])
        var input: Parser.Test.Input = [0x01, 0x02, 0x03]

        let result = parser.parse(&input)

        #expect(result == [0x01, 0x02, 0x03])
    }

    @Test
    func `returns empty when delimiter at start`() {
        let parser = Parser.Prefix.UpTo<Parser.Test.Input>([UInt8(ascii: "x")])
        var input = Parser.Test.Input(utf8: "xyz")

        let result = parser.parse(&input)

        #expect(result.isEmpty)
        #expect(input.first == UInt8(ascii: "x"))
    }

    @Test
    func `empty input returns empty result`() {
        let parser = Parser.Prefix.UpTo<Parser.Test.Input>([0x00])
        var input: Parser.Test.Input = []

        let result = parser.parse(&input)

        #expect(result.isEmpty)
    }
}

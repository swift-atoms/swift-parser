#if CollectionLeaves
import Collection
import Parser
import Collection_Parser_Test_Support
import Testing

@Suite
struct `Parser::Prefix.UpTo` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

extension `Parser::Prefix.UpTo`.Unit {
    @Test
    func `consumes up to delimiter without including it`() {
        let parser = Parser::Prefix.UpTo<CollectionParserTest.Input>([UInt8(ascii: ",")])
        var input = CollectionParserTest.Input(utf8: "hello,world")

        let result = parser.parse(&input)

        #expect(result == CollectionParserTest.Input(utf8: "hello"))
        #expect(input.first == UInt8(ascii: ","))
    }

    @Test
    func `handles multi-byte delimiter`() {
        let parser = Parser::Prefix.UpTo<CollectionParserTest.Input>(Swift.Array("-->".utf8))
        var input = CollectionParserTest.Input(utf8: "content-->rest")

        let result = parser.parse(&input)

        #expect(result == CollectionParserTest.Input(utf8: "content"))
    }
}

extension `Parser::Prefix.UpTo`.`Edge Case` {
    @Test
    func `consumes all when delimiter not found`() {
        let parser = Parser::Prefix.UpTo<CollectionParserTest.Input>([0xFF])
        var input: CollectionParserTest.Input = [0x01, 0x02, 0x03]

        let result = parser.parse(&input)

        #expect(result == [0x01, 0x02, 0x03])
    }

    @Test
    func `returns empty when delimiter at start`() {
        let parser = Parser::Prefix.UpTo<CollectionParserTest.Input>([UInt8(ascii: "x")])
        var input = CollectionParserTest.Input(utf8: "xyz")

        let result = parser.parse(&input)

        #expect(result.isEmpty)
        #expect(input.first == UInt8(ascii: "x"))
    }

    @Test
    func `empty input returns empty result`() {
        let parser = Parser::Prefix.UpTo<CollectionParserTest.Input>([0x00])
        var input: CollectionParserTest.Input = []

        let result = parser.parse(&input)

        #expect(result.isEmpty)
    }
}
#endif

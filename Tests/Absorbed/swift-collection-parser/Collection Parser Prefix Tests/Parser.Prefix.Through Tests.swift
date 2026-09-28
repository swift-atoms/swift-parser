#if CollectionLeaves
import Collection
import Parser
import Collection_Parser_Test_Support
import Testing

@Suite
struct `Parser::Prefix.Through` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

extension `Parser::Prefix.Through`.Unit {
    @Test
    func `consumes through delimiter including it`() throws(any Swift.Error) {
        let parser = Parser::Prefix.Through<CollectionParserTest.Input>([UInt8(ascii: "\n")])
        var input = CollectionParserTest.Input(utf8: "line1\nline2")

        let result = try parser.parse(&input)

        #expect(result == CollectionParserTest.Input(utf8: "line1\n"))
        #expect(input.first == UInt8(ascii: "l"))
    }

    @Test
    func `handles multi-byte delimiter`() throws(any Swift.Error) {
        let parser = Parser::Prefix.Through<CollectionParserTest.Input>(Swift.Array("\r\n".utf8))
        var input = CollectionParserTest.Input(utf8: "header\r\nbody")

        let result = try parser.parse(&input)

        #expect(result == CollectionParserTest.Input(utf8: "header\r\n"))
    }
}

extension `Parser::Prefix.Through`.`Edge Case` {
    @Test
    func `fails when delimiter not found`() {
        let parser = Parser::Prefix.Through<CollectionParserTest.Input>([0xFF])
        var input: CollectionParserTest.Input = [0x01, 0x02]

        #expect(throws: Parser::Prefix.Through<CollectionParserTest.Input>.Error.self) {
            try parser.parse(&input)
        }
    }

    @Test
    func `consumes entire input when delimiter at end`() throws(any Swift.Error) {
        let parser = Parser::Prefix.Through<CollectionParserTest.Input>([UInt8(ascii: "!")])
        var input = CollectionParserTest.Input(utf8: "ok!")

        let result = try parser.parse(&input)

        #expect(result == CollectionParserTest.Input(utf8: "ok!"))
        #expect(input.isEmpty)
    }
}
#endif

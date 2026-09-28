#if CollectionLeaves
import Collection
import Parser
import Tagged
import Collection_Parser_Test_Support
import Testing

@Suite
struct `Parser::Prefix.While` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

extension `Parser::Prefix.While`.Unit {
    @Test
    func `consumes while predicate holds`() throws(any Swift.Error) {
        let digits = Parser::Prefix.While<CollectionParserTest.Input> {
            $0 >= 0x30 && $0 <= 0x39
        }

        var input = CollectionParserTest.Input([0x31, 0x32, 0x33, 0x61, 0x62, 0x63])

        let result = try digits.parse(&input)

        #expect(result.count == 3)
        #expect(input.first == 0x61)
    }

    @Test
    func `consumes all input when predicate always holds`() throws(any Swift.Error) {
        let all = Parser::Prefix.While<CollectionParserTest.Input> { _ in true }
        var input = CollectionParserTest.Input([0x01, 0x02, 0x03])

        let result = try all.parse(&input)

        #expect(result.count == 3)
        #expect(input.isEmpty)
    }
}

extension `Parser::Prefix.While`.`Edge Case` {
    @Test
    func `returns empty when predicate immediately fails`() throws(any Swift.Error) {
        let parser = Parser::Prefix.While<CollectionParserTest.Input> { _ in false }
        var input = CollectionParserTest.Input([0x01, 0x02])

        let result = try parser.parse(&input)

        #expect(result.isEmpty)
    }

    @Test
    func `minLength enforcement fails when too few match`() {
        let parser = Parser::Prefix.While<CollectionParserTest.Input>(minLength: 3) {
            $0 >= 0x30 && $0 <= 0x39
        }

        var input = CollectionParserTest.Input([0x31, 0x32, 0x78])

        #expect(throws: Parser::Prefix.While<CollectionParserTest.Input>.Error.self) {
            try parser.parse(&input)
        }
    }

    @Test
    func `maxLength caps consumed count`() throws(any Swift.Error) {
        let parser = Parser::Prefix.While<CollectionParserTest.Input>(maxLength: 2) { _ in true }
        var input = CollectionParserTest.Input([0x01, 0x02, 0x03, 0x04])

        let result = try parser.parse(&input)

        #expect(result.count == 2)
        #expect(input.count == 2)
    }

    @Test
    func `empty input returns empty result`() throws(any Swift.Error) {
        let parser = Parser::Prefix.While<CollectionParserTest.Input> { _ in true }
        var input: CollectionParserTest.Input = []

        let result = try parser.parse(&input)

        #expect(result.isEmpty)
    }
}
#endif

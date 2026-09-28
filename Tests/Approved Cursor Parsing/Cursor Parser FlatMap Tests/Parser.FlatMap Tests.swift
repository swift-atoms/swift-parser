#if Choice && Repetition && IteratorLeaves && Always && Map && FlatMap && Either
import Parser
import Checkpoint
import Always
import Cursor_Parser_Test_Support
import Cursor
import Testing

@Suite
struct `FlatMap.Parser` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

extension `FlatMap.Parser`.Unit {
    @Test
    func `chains parsers where second depends on first output`() throws(any Swift.Error) {
        let parser = Parser::First.Element<ArraySlice<UInt8>>()
            .flatMap { count -> CursorParserTest.Take in
                CursorParserTest.Take(Int(count))
            }
        var input = ArraySlice<UInt8>([0x03, 0x0A, 0x0B, 0x0C, 0xFF])

        let result = try parser.parse(&input)

        #expect(result.count == 3)
        #expect(input.first == 0xFF)
    }
}

extension `FlatMap.Parser`.`Edge Case` {
    @Test
    func `upstream failure prevents downstream execution`() {
        let parser = Parser::First.Element<ArraySlice<UInt8>>()
            .flatMap { _ in Always<Int>.Parser<ArraySlice<UInt8>>(0) }
        var input = ArraySlice<UInt8>([])

        #expect(throws: (any Swift.Error).self) {
            try parser.parse(&input)
        }
    }

    @Test
    func `downstream failure propagates as right error`() {
        let parser = Always<UInt8>.Parser<ArraySlice<UInt8>>(5)
            .flatMap { count -> CursorParserTest.Take in
                CursorParserTest.Take(Int(count))
            }
        var input = ArraySlice<UInt8>([0x01, 0x02])

        #expect(throws: (any Swift.Error).self) {
            try parser.parse(&input)
        }
    }
}
#endif

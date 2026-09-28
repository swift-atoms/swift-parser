#if Choice && Repetition && IteratorLeaves && Always && Map && FlatMap && Either
import Parser
import Checkpoint
import Cursor_Parser_Test_Support
import Cursor
import Testing

@Suite
struct `Map.Parser.Transform` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

extension `Map.Parser.Transform`.Unit {
    @Test
    func `transforms output of upstream parser`() throws(any Swift.Error) {
        let parser = Parser::First.Element<ArraySlice<UInt8>>()
            .map { Int($0) }
        var input = ArraySlice<UInt8>([0x0A])

        let result = try parser.parse(&input)

        #expect(result == 10)
    }

    @Test
    func `preserves input consumption from upstream`() throws(any Swift.Error) {
        let parser = Parser::First.Element<ArraySlice<UInt8>>()
            .map { String($0, radix: 16) }
        var input = ArraySlice<UInt8>([0xFF, 0x01])

        _ = try parser.parse(&input)

        #expect(input.first == 0x01)
    }
}

extension `Map.Parser.Transform`.`Edge Case` {
    @Test
    func `upstream failure propagates through map`() {
        let parser = Parser::First.Element<ArraySlice<UInt8>>()
            .map { $0 * 2 }
        var input = ArraySlice<UInt8>([])

        #expect(throws: Parser::EndOfInput.Error.self) {
            try parser.parse(&input)
        }
    }
}
#endif

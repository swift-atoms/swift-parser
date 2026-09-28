#if Choice && Repetition && IteratorLeaves && Always && Map && FlatMap && Either
import Parser
import Checkpoint
import Cursor_Parser_Test_Support
import Cursor
import Testing

@Suite
struct `Parser::Optionally` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

extension `Parser::Optionally`.Unit {
    @Test
    func `returns value when parser succeeds`() throws {
        let parser = Parser::Optionally<Parser::First.Where<ArraySlice<UInt8>>>(rejected: { _ in true }) {
            Parser::First.Where<ArraySlice<UInt8>> { $0 == 0x41 }
        }
        var input = ArraySlice<UInt8>([0x41, 0x42])

        let result = try parser.parse(&input)

        #expect(result != nil)
        #expect(input.first == 0x42)
    }

    @Test
    func `returns nil when parser fails`() throws {
        let parser = Parser::Optionally<Parser::First.Where<ArraySlice<UInt8>>>(rejected: { _ in true }) {
            Parser::First.Where<ArraySlice<UInt8>> { $0 == 0x41 }
        }
        var input = ArraySlice<UInt8>([0x42])

        let result = try parser.parse(&input)

        #expect(result == nil)
    }
}

extension `Parser::Optionally`.`Edge Case` {
    @Test
    func `backtracks on failure`() throws {
        let parser = Parser::Optionally<Parser::First.Where<ArraySlice<UInt8>>>(rejected: { _ in true }) {
            Parser::First.Where<ArraySlice<UInt8>> { $0 == 0xFF }
        }
        var input = ArraySlice<UInt8>([0x01, 0x02])

        _ = try parser.parse(&input)

        #expect(input.first == 0x01)
    }

    @Test
    func `returns nil on empty input`() throws {
        let parser = Parser::Optionally<Parser::First.Element<ArraySlice<UInt8>>>(rejected: { _ in true }) {
            Parser::First.Element<ArraySlice<UInt8>>()
        }
        var input = ArraySlice<UInt8>([])

        let result = try parser.parse(&input)

        #expect(result == nil)
    }
}
#endif

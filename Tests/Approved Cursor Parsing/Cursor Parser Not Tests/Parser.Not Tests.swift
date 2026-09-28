#if Choice && Repetition && IteratorLeaves && Always && Map && FlatMap && Either
import Parser
import Checkpoint
import Cursor_Parser_Test_Support
import Cursor
import Testing

@Suite
struct `Parser::Not` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

extension `Parser::Not`.Unit {
    @Test
    func `succeeds when upstream fails`() throws(any Swift.Error) {
        let parser = Parser::First.Where<ArraySlice<UInt8>> { $0 == 0x41 }.not(rejected: { _ in true })
        var input = ArraySlice<UInt8>([0x42])

        try parser.parse(&input)

        #expect(input.first == 0x42)
    }

    @Test
    func `never consumes input on success`() throws(any Swift.Error) {
        let parser = Parser::First.Where<ArraySlice<UInt8>> { $0 == 0xFF }
            .not(rejected: { _ in true })
        var input = ArraySlice<UInt8>([0x01, 0x02])

        try parser.parse(&input)

        #expect(input.first == 0x01)
    }
}

extension `Parser::Not`.`Edge Case` {
    @Test
    func `fails when upstream succeeds`() {
        let parser = Parser::First.Where<ArraySlice<UInt8>> { $0 == 0x41 }.not(rejected: { _ in true })
        var input = ArraySlice<UInt8>([0x41])

        #expect(throws: Parser::Not<Parser::First.Where<ArraySlice<UInt8>>>.Error.self) {
            try parser.parse(&input)
        }
    }

    @Test
    func `never consumes input on failure`() {
        let parser = Parser::First.Where<ArraySlice<UInt8>> { $0 == 0x41 }.not(rejected: { _ in true })
        var input = ArraySlice<UInt8>([0x41, 0x42])

        _ = try? parser.parse(&input)

        #expect(input.first == 0x41)
    }

    @Test
    func `succeeds on empty input when upstream requires elements`() throws(any Swift.Error) {
        let parser = Parser::First.Element<ArraySlice<UInt8>>().not(rejected: { _ in true })
        var input = ArraySlice<UInt8>([])

        try parser.parse(&input)
    }
}
#endif

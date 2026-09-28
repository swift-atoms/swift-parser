#if Choice && Repetition && IteratorLeaves && Always && Map && FlatMap && Either
import Parser
import Checkpoint
import Always
import Cursor_Parser_Test_Support
import Cursor
import Testing

@Suite
struct `Parser::Many` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

extension `Parser::Many`.Unit {
    @Test
    func `zero or more collects all matching elements`() throws(any Swift.Error) {
        let parser = Parser::Many(rejected: { _ in true }) {
            Parser::First.Where<ArraySlice<UInt8>> { $0 == 0x41 }
        }
        var input = ArraySlice<UInt8>([0x41, 0x41, 0x41, 0x42])

        let result = try parser.parse(&input)

        #expect(result.count == 3)
        #expect(input.first == 0x42)
    }

    @Test
    func `one or more requires at least one match`() throws(any Swift.Error) {
        let parser = Parser::Many(1..., rejected: { _ in true }) {
            Parser::First.Element<ArraySlice<UInt8>>()
        }
        var input = ArraySlice<UInt8>([0x0A, 0x0B])

        let result = try parser.parse(&input)

        #expect(result == [0x0A, 0x0B])
    }

    @Test
    func `exact count with closed range`() throws(any Swift.Error) {
        let parser = Parser::Many(2...2, rejected: { _ in true }) {
            Parser::First.Element<ArraySlice<UInt8>>()
        }
        var input = ArraySlice<UInt8>([0x01, 0x02, 0x03])

        let result = try parser.parse(&input)

        #expect(result == [0x01, 0x02])
        #expect(input.first == 0x03)
    }
}

extension `Parser::Many`.`Edge Case` {

    @Test
    func `terminates after a non-consuming success`() throws(any Swift.Error) {
        let parser = Parser::Many<ArraySlice<UInt8>, Always<Int>.Parser<ArraySlice<UInt8>>>(rejected: { _ in false }) {
            Always<Int>.Parser<ArraySlice<UInt8>>(42)
        }
        var input = ArraySlice<UInt8>([0x41])

        #expect(throws: Parser::Many<ArraySlice<UInt8>, Always<Int>.Parser<ArraySlice<UInt8>>>.Error.noProgress) {
            try parser.parse(&input)
        }
        #expect(input.first == 0x41)
    }

    @Test
    func `zero or more returns empty on no match`() throws(any Swift.Error) {
        let parser = Parser::Many(rejected: { _ in true }) {
            Parser::First.Where<ArraySlice<UInt8>> { $0 == 0xFF }
        }
        var input = ArraySlice<UInt8>([0x01])

        let result = try parser.parse(&input)

        #expect(result.isEmpty)
        #expect(input.first == 0x01)
    }

    @Test
    func `one or more fails on empty input`() {
        let parser = Parser::Many(1..., rejected: { _ in true }) {
            Parser::First.Element<ArraySlice<UInt8>>()
        }
        var input = ArraySlice<UInt8>([])

        #expect(
            throws: Parser::Many<ArraySlice<UInt8>, Parser::First.Element<ArraySlice<UInt8>>>.Error
                .self
        ) {
            try parser.parse(&input)
        }
    }

    @Test
    func `zero or more succeeds on empty input`() throws(any Swift.Error) {
        let parser = Parser::Many(rejected: { _ in true }) {
            Parser::First.Element<ArraySlice<UInt8>>()
        }
        var input = ArraySlice<UInt8>([])

        let result = try parser.parse(&input)

        #expect(result.isEmpty)
    }
}
#endif

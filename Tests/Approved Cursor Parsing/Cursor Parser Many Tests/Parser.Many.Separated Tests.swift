#if Choice && Repetition && IteratorLeaves && Always && Map && FlatMap && Either
import Parser
import Checkpoint
import Cursor_Parser_Test_Support
import Cursor
import Testing

@Suite
struct `Parser::Many.Separated` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
}

extension `Parser::Many.Separated`.Unit {
    @Test
    func `parses comma-separated bytes`() throws(any Swift.Error) {
        let parser = Parser::Many.Separated(rejected: { _ in true }, separatorRejected: { _ in true }) {
            Parser::First.Element<ArraySlice<UInt8>>()
        } separator: {
            Parser::First.Where<ArraySlice<UInt8>> { $0 == UInt8(ascii: ",") }
        }
        var input = Array("a,b,c".utf8)[...]

        let result = try parser.parse(&input)

        #expect(result.count == 3)
        #expect(result[0] == UInt8(ascii: "a"))
        #expect(result[1] == UInt8(ascii: "b"))
        #expect(result[2] == UInt8(ascii: "c"))
    }

    @Test
    func `single element without separator`() throws(any Swift.Error) {
        let parser = Parser::Many.Separated(rejected: { _ in true }, separatorRejected: { _ in true }) {
            Parser::First.Element<ArraySlice<UInt8>>()
        } separator: {
            Parser::First.Where<ArraySlice<UInt8>> { $0 == UInt8(ascii: ",") }
        }
        var input = ArraySlice<UInt8>([0x42])

        let result = try parser.parse(&input)

        #expect(result == [0x42])
    }
}

extension `Parser::Many.Separated`.`Edge Case` {
    @Test
    func `empty input returns empty array`() throws(any Swift.Error) {
        let parser = Parser::Many.Separated(rejected: { _ in true }, separatorRejected: { _ in true }) {
            Parser::First.Where<ArraySlice<UInt8>> { $0 == 0x41 }
        } separator: {
            Parser::First.Where<ArraySlice<UInt8>> { $0 == UInt8(ascii: ",") }
        }
        var input = ArraySlice<UInt8>([])

        let result = try parser.parse(&input)

        #expect(result.isEmpty)
    }

    @Test
    func `trailing separator not consumed`() throws(any Swift.Error) {
        let parser = Parser::Many.Separated(rejected: { _ in true }, separatorRejected: { _ in true }) {
            Parser::First.Where<ArraySlice<UInt8>> { $0 == UInt8(ascii: "x") }
        } separator: {
            Parser::First.Where<ArraySlice<UInt8>> { $0 == UInt8(ascii: ",") }
        }
        var input = Array("x,x,".utf8)[...]

        let result = try parser.parse(&input)

        #expect(result.count == 2)
        #expect(input.first == UInt8(ascii: ","))
    }

    @Test
    func `minimum count enforcement`() {
        let parser = Parser::Many.Separated(3..., rejected: { _ in true }, separatorRejected: { _ in true }) {
            Parser::First.Where<ArraySlice<UInt8>> { $0 == UInt8(ascii: "a") }
        } separator: {
            Parser::First.Where<ArraySlice<UInt8>> { $0 == UInt8(ascii: ",") }
        }
        var input = Array("a,a".utf8)[...]

        #expect(
            throws: Parser::Many<ArraySlice<UInt8>, Parser::First.Where<ArraySlice<UInt8>>>
                .Separated<Parser::First.Where<ArraySlice<UInt8>>>.Error.self
        ) {
            try parser.parse(&input)
        }
    }
}
#endif

#if Choice && Repetition && IteratorLeaves && Always && Map && FlatMap && Either
import Parser
import Checkpoint
import Always
import Cursor_Parser_Test_Support
import Cursor
import Testing

private enum Choice: Equatable {
    case a
    case b
}

@Suite
struct `Parser::OneOf.Sequence` {
    @Suite struct `Builder Propagation` {}
}

extension `Parser::OneOf.Sequence`.`Builder Propagation` {

    @Test
    func `builder-composed alternation parses through the first matching branch`() throws(any Swift
        .Error)
    {
        let alternation = Parser::OneOf.Two(
            Always<Void>.Parser<ArraySlice<UInt8>>(()).map { _ in Choice.a },
            Always<Void>.Parser<ArraySlice<UInt8>>(()).map { _ in Choice.b },
            rejectFirst: { _ in false }, rejectSecond: { _ in false }
        )

        var input: ArraySlice<UInt8> = [0x41]
        #expect(try alternation.parse(&input) == .a)
    }
}
#endif

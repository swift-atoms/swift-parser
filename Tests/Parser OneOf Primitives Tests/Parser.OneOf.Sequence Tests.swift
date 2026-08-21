import Parser_Primitives_Test_Support
import Testing

private enum Choice: Equatable {
    case a
    case b
}

@Suite
struct `Parser.OneOf.Sequence` {
    @Suite struct `Builder Propagation` {}
}

extension `Parser.OneOf.Sequence`.`Builder Propagation` {

    @Test
    func `builder-composed alternation parses through the first matching branch`() throws(any Swift
        .Error)
    {
        let alternation = Parser.OneOf.Sequence {
            Parser.Always<Parser.Test.Input, Void>(()).map(.fixed(Choice.a))
            Parser.Always<Parser.Test.Input, Void>(()).map(.fixed(Choice.b))
        }

        var input: Parser.Test.Input = [0x41]
        #expect(try alternation.parse(&input) == .a)
    }
}

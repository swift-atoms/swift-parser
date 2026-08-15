import Parser_Primitives_Test_Support
import Testing

// MARK: - Test Support Types

/// A two-case label the alternation discriminates.
private enum Choice: Equatable {
    case a
    case b
}

// MARK: - Test Suite Structure

@Suite
struct `Parser.OneOf.Sequence` {
    @Suite struct `Builder Propagation` {}
}

// MARK: - Builder Propagation

extension `Parser.OneOf.Sequence`.`Builder Propagation` {
    /// An alternation built through `Parser.OneOf.Sequence { … }` parses by
    /// delegating to the composed `Parser.OneOf.Two` body.
    ///
    /// The emission direction of this wrapper (the serializer-side row) lives
    /// in swift-coder-primitives; only the parse direction is native here.
    @Test
    func `builder-composed alternation parses through the first matching branch`() throws(any Swift
        .Error)
    {
        let alternation = Parser.OneOf.Sequence {
            Parser.Always<Parser.Test.Input, Void>(()).map(.fixed(Choice.a))
            Parser.Always<Parser.Test.Input, Void>(()).map(.fixed(Choice.b))
        }

        // parse — the first (always-succeeding) branch wins.
        var input: Parser.Test.Input = [0x41]
        #expect(try alternation.parse(&input) == .a)
    }
}

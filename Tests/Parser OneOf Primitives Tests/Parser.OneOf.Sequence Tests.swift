import Parser_Primitives_Test_Support
import Testing

// MARK: - Test Support Types

/// A two-case label the alternation discriminates when printing.
private enum Choice: Equatable {
    case a
    case b
}

/// Statically requires `P` to be a ``Parser/Printer`` — proves at compile time
/// that the builder-entry wrapper `Parser.OneOf.Sequence` regained its printer
/// conformance (friction F4).
private func requirePrinter<P: Parser.Printer>(_ parser: P) -> P { parser }

// MARK: - Test Suite Structure

@Suite
struct `Parser.OneOf.Sequence` {
    @Suite struct `Printer Propagation` {}
}

// MARK: - Printer Propagation

extension `Parser.OneOf.Sequence`.`Printer Propagation` {
    /// An alternation built through `Parser.OneOf.Sequence { … }` prints — the
    /// F4 fix.
    ///
    /// Each branch is a `Void`-parser (`Parser.Always`) lifted to a
    /// labelled output through `.map(.fixed(_))`, so both branches are printers;
    /// the wrapper must forward `print` to the composed `Parser.OneOf.Two`, and
    /// the `.b` direction only succeeds if that forwarding drives the OneOf
    /// print-backtrack into the second branch.
    @Test
    func `builder-composed alternation prints through both branches`() throws(any Swift.Error) {
        let alternation = requirePrinter(
            Parser.OneOf.Sequence {
                Parser.Always<Parser.Test.Input, Void>(()).map(.fixed(Choice.a))
                Parser.Always<Parser.Test.Input, Void>(()).map(.fixed(Choice.b))
            }
        )

        // parse — the first (always-succeeding) branch wins.
        var input: Parser.Test.Input = [0x41]
        #expect(try alternation.parse(&input) == .a)

        // print `.a` — served by the first branch directly.
        var firstOutput: Parser.Test.Input = []
        try alternation.print(Choice.a, into: &firstOutput)

        // print `.b` — the first branch's `.fixed(.a)` un-apply mismatches, so
        // the OneOf printer backtracks into the second branch. This throws
        // unless `OneOf.Sequence` forwards `print` to its body.
        var secondOutput: Parser.Test.Input = []
        try alternation.print(Choice.b, into: &secondOutput)
    }
}

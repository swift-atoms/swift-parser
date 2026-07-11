//
//  Parser.OneOf.Sequence+Printer.swift
//  swift-parser-primitives
//
//  Builder-propagation fix: forward printing through the OneOf.Sequence
//  builder-entry wrapper to its composed body.
//
//  Mirrors `Parser.Take.Sequence+Printer.swift`. Without this, an alternation
//  composed via `Parser.OneOf.Sequence { … }` parses but cannot print — the
//  wrapper delegated only `parse` to `body`, so a builder-composed alternation
//  lost its `Parser.Printer` conformance at the entry point even when every
//  `Parser.OneOf.Two` / `Parser.OneOf.Three` node it wraps was itself a printer
//  (they conform in `Parser.OneOf.Two.swift` / `Parser.OneOf.Three.swift`). This
//  forwards `print` (and completes the `Bidirectional` conformance) whenever the
//  composed body is a printer.
//

extension Parser.OneOf.Sequence: Parser.Printer where Body: Parser.Printer {
    /// Prints by delegating to the composed body.
    @inlinable
    public func print(_ output: Output, into input: inout Input) throws(Failure) {
        try body.print(output, into: &input)
    }
}

extension Parser.OneOf.Sequence: Parser.Bidirectional where Body: Parser.Bidirectional {}

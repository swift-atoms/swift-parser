//
//  Parser.Take.Sequence+Printer.swift
//  swift-parser-primitives
//
//  Builder-propagation fix: forward printing through the Take.Sequence
//  builder-entry wrapper to its composed body.
//
//  Without this, a grammar composed via `Parser.Take.Sequence { … }` parses but
//  cannot print — the wrapper delegated only `parse` to `body`, so a builder-
//  composed parser-printer lost its `Parser.Printer` conformance at the entry
//  point even when every leaf and every `Take.Two` / `Skip.First` / `Skip.Second`
//  node in the body was itself a printer. This forwards `print` (and completes
//  the `Bidirectional` conformance) whenever the composed body is a printer.
//
//  Remaining gap (out of scope here): builder bodies that flatten 3-plus value
//  outputs through `Parser.Take.Two.Map` are NOT printers — that node maps its
//  tuple with an opaque one-way closure and cannot be inverted. Restoring
//  printability there needs a dedicated bidirectional variadic-flatten
//  combinator. See the task report's remaining-gap list.
//

extension Parser.Take.Sequence: Parser.Printer where Body: Parser.Printer {
    /// Prints by delegating to the composed body.
    @inlinable
    public func print(_ output: Output, into input: inout Input) throws(Failure) {
        try body.print(output, into: &input)
    }
}

extension Parser.Take.Sequence: Parser.Bidirectional where Body: Parser.Bidirectional {}

//
//  Parser.OneOf.Two.swift
//  swift-standards
//
//  Two-parser alternative combinator.
//

public import Input_Primitives
public import Product_Primitives

extension Parser.OneOf {
    /// A parser that tries two alternatives.
    ///
    /// Type-safe variant for exactly two parsers. Used by result builders.
    public struct Two<P0: Parser.`Protocol`, P1: Parser.`Protocol`>
    where
        P0.Input == P1.Input,
        P0.Output == P1.Output,
        P0.Input: Input_Primitives.Input.`Protocol`
    {
        @usableFromInline
        let p0: P0

        @usableFromInline
        let p1: P1

        /// Creates a parser that tries the first parser, falling back to the second.
        @inlinable
        public init(_ p0: P0, _ p1: P1) {
            self.p0 = p0
            self.p1 = p1
        }
    }
}

extension Parser.OneOf.Two: Parser.`Protocol` {
    /// The input type this parser consumes.
    public typealias Input = P0.Input
    /// The output type both alternatives produce.
    public typealias Output = P0.Output
    /// The error type this parser can throw, combining both alternatives' errors.
    public typealias Failure = Product<P0.Failure, P1.Failure>

    // on Property.Inout accessor chains (input.restore.to) in multiple control flow paths.
    /// Tries the first parser; on failure, backtracks and tries the second.
    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        let checkpoint = input.checkpoint

        do throws(P0.Failure) {
            return try p0.parse(&input)
        } catch let error0 {
            input.restore.to(__unchecked: (), checkpoint)
            do throws(P1.Failure) {
                return try p1.parse(&input)
            } catch let error1 {
                throw Failure(error0, error1)
            }
        }
    }
}

// MARK: - Printer Conformance

extension Parser.OneOf.Two: Parser.Printer
where P0: Parser.Printer, P1: Parser.Printer {
    /// Tries the first printer; on failure, backtracks and tries the second.
    @inlinable
    public func print(_ output: Output, into input: inout Input) throws(Failure) {
        // Try first printer, fall back to second
        let checkpoint = input.checkpoint
        do throws(P0.Failure) {
            try p0.print(output, into: &input)
            return
        } catch let error0 {
            input.restore.to(__unchecked: (), checkpoint)
            do throws(P1.Failure) {
                try p1.print(output, into: &input)
            } catch let error1 {
                throw Failure(error0, error1)
            }
        }
    }
}

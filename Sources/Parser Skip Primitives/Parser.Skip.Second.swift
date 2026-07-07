//
//  Parser.Skip.Second.swift
//  swift-standards
//
//  Skip second parser's Void output.
//

extension Parser.Skip {
    /// A parser that runs two parsers but discards the second's output.
    ///
    /// Used when the second parser has `Void` output (like a delimiter).
    public struct Second<P0: Parser.`Protocol`, P1: Parser.`Protocol`>
    where P0.Input == P1.Input, P1.Output == Void {
        @usableFromInline
        internal let p0: P0

        @usableFromInline
        internal let p1: P1

        /// Creates a parser that runs both parsers but keeps only the first's output.
        @inlinable
        public init(_ p0: P0, _ p1: P1) {
            self.p0 = p0
            self.p1 = p1
        }
    }
}

extension Parser.Skip.Second: Parser.`Protocol` {
    /// The input type this parser consumes.
    public typealias Input = P0.Input
    /// The output type this parser produces: the first parser's output.
    public typealias Output = P0.Output
    /// The error type this parser can throw, discriminating which parser failed.
    public typealias Failure = Either<P0.Failure, P1.Failure>

    /// Parses and returns the first parser's output, then parses and discards the second.
    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        let o0: P0.Output
        do throws(P0.Failure) {
            o0 = try p0.parse(&input)
        } catch {
            throw .left(error)
        }
        do throws(P1.Failure) {
            _ = try p1.parse(&input)
        } catch {
            throw .right(error)
        }
        return o0
    }
}

// MARK: - Printer Conformance

extension Parser.Skip.Second: Parser.Printer
where P0: Parser.Printer, P1: Parser.Printer {
    /// Prints the second parser's empty output, then the first parser's output, in reverse order.
    @inlinable
    public func print(_ output: P0.Output, into input: inout Input) throws(Failure) {
        // Print in reverse order
        do throws(P1.Failure) {
            try p1.print((), into: &input)
        } catch {
            throw .right(error)
        }
        do throws(P0.Failure) {
            try p0.print(output, into: &input)
        } catch {
            throw .left(error)
        }
    }
}

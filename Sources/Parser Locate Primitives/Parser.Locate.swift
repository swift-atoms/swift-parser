//
//  Parser.Locate.swift
//  swift-standards
//
//  Parser that wraps errors with location information.
//

public import Input_Primitives

extension Parser {
    /// A parser that wraps errors with their location.
    ///
    /// Transforms `Failure` to `Located<Failure>` by capturing the
    /// byte offset when an error occurs.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// var input = Parser.Tracked(source)
    /// let parser = Parser.Locate(myParser)
    /// // Errors now include offset information
    /// ```
    public struct Locate<Base: Input_Primitives.Input.`Protocol`, Upstream: Parser.`Protocol`>
    where Upstream.Input == Base {
        @usableFromInline
        let upstream: Upstream

        /// Creates a parser that annotates the upstream parser's failures with their location.
        @inlinable
        public init(_ upstream: Upstream) {
            self.upstream = upstream
        }
    }
}

extension Parser.Locate: Parser.`Protocol` {
    /// The input type this parser consumes: offset-tracking input.
    public typealias Input = Parser.Tracked<Base>
    /// The output type this parser produces, unchanged from the upstream parser.
    public typealias Output = Upstream.Output
    /// The error type this parser can throw, annotated with the failure location.
    public typealias Failure = Parser.Error.Located<Upstream.Failure>

    /// Parses the upstream value; failures are wrapped with the offset at which they occurred.
    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        try input.parseTracked(upstream).output
    }
}

// MARK: - Parser Extension

extension Parser.`Protocol` where Input: Input_Primitives.Input.`Protocol` & Copyable {
    /// Wraps this parser to produce located errors.
    ///
    /// The returned parser requires `Tracked<Input>` and produces
    /// `Located<Failure>` errors with byte offsets.
    @inlinable
    public func located() -> Parser.Locate<Input, Self> {
        Parser.Locate(self)
    }
}

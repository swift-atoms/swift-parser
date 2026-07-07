//
//  Parser.Span.swift
//  swift-standards
//
//  Span parser that wraps output with source location.
//

public import Input_Primitives

extension Parser {
    /// A parser that wraps output with its source span.
    ///
    /// Captures start and end offsets around the upstream parser,
    /// producing `Spanned<Output>`.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// var input = Parser.Tracked(source)
    /// let parser = Parser.Span(identifierParser)
    /// let result = try parser.parse(&input)
    /// print("Identifier '\(result.value)' at \(result.start)..<\(result.end)")
    /// ```
    public struct Span<Base: Input_Primitives.Input.`Protocol`, Upstream: Parser.`Protocol`>
    where Upstream.Input == Base {
        @usableFromInline
        let upstream: Upstream

        /// Creates a parser that annotates the upstream parser's output with its source span.
        @inlinable
        public init(_ upstream: Upstream) {
            self.upstream = upstream
        }
    }
}

extension Parser.Span: Parser.`Protocol` {
    /// The input type this parser consumes: offset-tracking input.
    public typealias Input = Parser.Tracked<Base>
    /// The output type this parser produces: the upstream output paired with its span.
    public typealias Output = Parser.Spanned<Upstream.Output>
    /// The error type this parser can throw, annotated with the failure location.
    public typealias Failure = Parser.Error.Located<Upstream.Failure>

    /// Parses the upstream value, capturing the start and end offsets that bound it.
    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        let (value, start) = try input.parseTracked(upstream)
        return Parser.Spanned(value, start: start, end: input.currentOffset)
    }
}

// MARK: - Parser Extension

extension Parser.`Protocol` where Input: Input_Primitives.Input.`Protocol` & Copyable {
    /// Wraps this parser to produce spanned output.
    ///
    /// The returned parser requires `Tracked<Input>` and produces
    /// `Spanned<Output>` with start/end offsets.
    @inlinable
    public func spanned() -> Parser.Span<Input, Self> {
        Parser.Span(self)
    }
}

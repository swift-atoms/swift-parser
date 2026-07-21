//
//  Parser.Optional.swift
//  swift-standards
//
//  Compile-time optional parser (for result builders).
//

extension Parser {
    /// A parser that optionally parses if its wrapped parser is present.
    ///
    /// Used by `Take.Builder` for `if` statements without `else`.
    public struct Optional<Wrapped: Parser.`Protocol`> {
        @usableFromInline
        let wrapped: Wrapped?

        /// Creates a parser wrapping an optional parser.
        @inlinable
        public init(_ wrapped: Wrapped?) {
            self.wrapped = wrapped
        }
    }
}

extension Parser.Optional: Parser.`Protocol` {
    /// The input type this parser consumes.
    public typealias Input = Wrapped.Input
    /// The output type this parser produces: the wrapped output, or nil when absent.
    public typealias Output = Wrapped.Output?
    /// The error type this parser can throw, inherited from the wrapped parser.
    public typealias Failure = Wrapped.Failure

    /// Parses using the wrapped parser when present, otherwise returns nil.
    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        guard let wrapped else {
            return nil
        }
        return try wrapped.parse(&input)
    }
}

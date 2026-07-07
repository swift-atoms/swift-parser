//
//  Parser.Take.Sequence.swift
//  swift-standards
//
//  Entry point for building sequential parsers.
//

extension Parser.Take {
    /// Entry point for building parsers with result builder syntax.
    ///
    /// `Sequence` provides a convenient way to compose parsers using Swift's
    /// result builder syntax. The resulting parser type is inferred from
    /// the builder contents.
    ///
    /// ## Basic Usage
    ///
    /// ```swift
    /// let keyValue = Parser.Take.Sequence {
    ///     Parser.Prefix.While { $0 != UInt8(ascii: "=") }  // key
    ///     "="                                                // delimiter (discarded)
    ///     Parser.Rest()                                     // value
    /// }
    /// // Type: Parser with Output = (Substring, Substring) or similar
    /// ```
    public struct Sequence<Input, Output, Body: Parser.`Protocol`>
    where Body.Input == Input, Body.Output == Output {
        /// The composed parser built from the sequence.
        public let body: Body

        /// Creates a sequential parser from the given result-builder closure.
        @inlinable
        public init(
            @Parser.Take.Builder<Input> _ build: () -> Body
        ) {
            self.body = build()
        }
    }
}

extension Parser.Take.Sequence: Parser.`Protocol` {
    /// The error type this parser can throw, inherited from the composed body.
    public typealias Failure = Body.Failure

    /// Parses by delegating to the composed body.
    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        try body.parse(&input)
    }
}

//
//  Parser.OneOf.Sequence.swift
//  swift-standards
//
//  Entry point for building alternative parsers.
//

extension Parser.OneOf {
    /// Entry point for building alternative parsers.
    ///
    /// `Sequence` tries each parser in order until one succeeds.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let boolean = Parser.OneOf.Sequence {
    ///     "true".map { true }
    ///     "false".map { false }
    /// }
    /// ```
    public struct Sequence<Input, Output, Body: Parser.`Protocol`>
    where Body.Input == Input, Body.Output == Output {
        /// The composed parser built from the alternatives.
        public let body: Body

        /// Creates an alternative parser from the given result-builder closure.
        @inlinable
        public init(
            @Parser.OneOf.Builder<Input, Output> _ build: () -> Body
        ) {
            self.body = build()
        }
    }
}

extension Parser.OneOf.Sequence: Parser.`Protocol` {
    /// The error type this parser can throw, inherited from the composed body.
    public typealias Failure = Body.Failure

    /// Parses by delegating to the composed body.
    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        try body.parse(&input)
    }
}

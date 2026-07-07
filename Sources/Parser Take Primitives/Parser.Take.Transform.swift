//
//  Parser.Take.Transform.swift
//  swift-standards
//
//  Entry point for building transforming parsers.
//

extension Parser.Take {
    /// A parser that transforms its body's output.
    ///
    /// Enables constructing domain types from parsed tuples:
    ///
    /// ```swift
    /// let point = Parser.Take.Transform(Point.init) {
    ///     IntParser()
    ///     ","
    ///     IntParser()
    /// }
    /// ```
    public struct Transform<Input, BodyOutput, Output, Body: Parser.`Protocol`>
    where Body.Input == Input, Body.Output == BodyOutput {
        /// The composed parser built from the sequence.
        public let body: Body

        @usableFromInline
        let transform: (BodyOutput) -> Output

        /// Creates a transforming parser from the transform and the result-builder closure.
        @inlinable
        public init(
            _ transform: @escaping (BodyOutput) -> Output,
            @Parser.Take.Builder<Input> _ build: () -> Body
        ) {
            self.body = build()
            self.transform = transform
        }
    }
}

extension Parser.Take.Transform: Parser.`Protocol` {
    /// The error type this parser can throw, inherited from the composed body.
    public typealias Failure = Body.Failure

    /// Parses the body, then applies the transform to its output.
    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        transform(try body.parse(&input))
    }
}

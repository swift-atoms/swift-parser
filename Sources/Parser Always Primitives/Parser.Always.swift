//
//  Parser.Always.swift
//  swift-standards
//
//  Always-succeeding parser.
//

extension Parser {
    /// A parser that always succeeds without consuming input.
    ///
    /// `Always` is useful as an identity element and for injecting values.
    public struct Always<Input, Output> {
        /// The value this parser always produces.
        public let output: Output

        /// Creates a parser that always produces the given value.
        @inlinable
        public init(_ output: Output) {
            self.output = output
        }
    }
}

extension Parser.Always: Parser.`Protocol` {
    /// This parser is infallible.
    public typealias Failure = Never

    /// Returns the stored value without consuming input.
    @inlinable
    public func parse(_ input: inout Input) -> Output {
        output
    }
}

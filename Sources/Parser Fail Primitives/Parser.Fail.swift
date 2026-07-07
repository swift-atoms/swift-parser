//
//  Parser.Fail.swift
//  swift-standards
//
//  Always-failing parser.
//

extension Parser {
    /// A parser that always fails with a specified error.
    ///
    /// `Fail` is useful as a fallback in error handling scenarios.
    /// The error type is specified as a generic parameter.
    public struct Fail<Input, Output, F: Swift.Error>: Sendable {
        @usableFromInline
        let error: F

        /// Creates a parser that always fails with the given error.
        @inlinable
        public init(_ error: F) {
            self.error = error
        }
    }
}

extension Parser.Fail: Parser.`Protocol` {
    /// The error type this parser always throws.
    public typealias Failure = F

    /// Always throws the stored error without consuming input.
    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        throw error
    }
}

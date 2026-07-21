//
//  Parser.End.swift
//  swift-parser-primitives
//
//  End-of-input parser.
//

public import Collection_Primitives

extension Parser {
    /// A parser that succeeds only at end of input.
    ///
    /// Consumes nothing and produces Void. Fails if input remains.
    public struct End<Input: Collection.Slice.`Protocol`> {
        /// Creates an end-of-input parser.
        @inlinable
        public init() {}
    }
}

extension Parser.End: Parser.`Protocol` {
    /// This parser produces no value.
    public typealias Output = Void
    /// The error type this parser can throw when input remains.
    public typealias Failure = Parser.Match.Error

    /// Succeeds only when the input is exhausted, otherwise fails.
    @inlinable
    public func parse(_ input: inout Input) throws(Failure) {
        guard input.isEmpty else {
            throw .expectedEnd(remaining: input.remainingCount)
        }
    }
}

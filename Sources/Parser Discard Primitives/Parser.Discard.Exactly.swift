//
//  Parser.Discard.Exactly.swift
//  swift-parser-primitives
//
//  Discard exactly N elements.
//

public import Collection_Primitives

extension Parser.Discard {
    /// A parser that skips N elements without returning them.
    public struct Exactly<Input: Collection.Slice.`Protocol`> {
        @usableFromInline
        let count: Int

        /// Creates a parser that skips the given number of elements.
        @inlinable
        public init(_ count: Int) {
            self.count = count
        }
    }
}

extension Parser.Discard.Exactly: Parser.`Protocol` {
    /// This parser produces no value.
    public typealias Output = Void
    /// The error type this parser can throw when fewer than the requested elements remain.
    public typealias Failure = Parser.Constraint.Error

    /// Skips exactly the requested number of elements, failing if too few remain.
    @inlinable
    public func parse(_ input: inout Input) throws(Failure) {
        _ = try Parser.Consume.Exactly<Input>(count).parse(&input)
    }
}

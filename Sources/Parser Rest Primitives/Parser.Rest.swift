//
//  Parser.Rest.swift
//  swift-parser-primitives
//
//  Consume all remaining input.
//

public import Collection_Primitives

extension Parser {
    /// A parser that consumes and returns all remaining input.
    ///
    /// Always succeeds, possibly with empty output.
    public struct Rest<Input: Collection.Slice.`Protocol`> {
        /// Creates a parser consuming all remaining input.
        @inlinable
        public init() {}
    }
}

extension Parser.Rest: Parser.`Protocol` {
    /// The output type this parser produces: the remaining input.
    public typealias Output = Input
    /// This parser is infallible.
    public typealias Failure = Never

    /// Consumes and returns all remaining input, leaving the input empty.
    @inlinable
    public func parse(_ input: inout Input) -> Output {
        let result = input
        input = input[input.endIndex...]
        return result
    }
}

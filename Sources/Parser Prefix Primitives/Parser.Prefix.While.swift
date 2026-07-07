//
//  Parser.Prefix.While.swift
//  swift-parser-primitives
//
//  Prefix parser that consumes while predicate holds.
//

public import Collection_Primitives

extension Parser.Prefix {
    /// A parser that consumes elements while a predicate holds.
    ///
    /// `While` is fundamental for tokenization. It greedily consumes elements
    /// until the predicate returns false or input is exhausted.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Parse digits
    /// let digits = Parser.Prefix.While { $0 >= 0x30 && $0 <= 0x39 }
    ///
    /// // Parse until delimiter
    /// let field = Parser.Prefix.While { $0 != UInt8(ascii: ",") }
    /// ```
    public struct While<Input: Collection.Slice.`Protocol`>
    where Input.Element: Copyable {
        @usableFromInline
        let minLength: Int

        /// `Int.max` means no maximum.
        @usableFromInline
        let maxLength: Int

        @usableFromInline
        let predicate: (Input.Element) -> Bool

        /// Creates a parser consuming elements while the predicate holds, within the length bounds.
        @inlinable
        public init(
            minLength: Int = 0,
            maxLength: Int? = nil,
            _ predicate: @escaping (Input.Element) -> Bool
        ) {
            self.minLength = minLength
            self.maxLength = maxLength ?? .max
            self.predicate = predicate
        }
    }
}

extension Parser.Prefix.While: Parser.`Protocol` {
    /// The output type this parser produces: the consumed prefix.
    public typealias Output = Input
    /// The error type this parser can throw when fewer than the minimum elements match.
    public typealias Failure = Parser.Constraint.Error

    /// Greedily consumes elements while the predicate holds, up to the maximum length.
    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        var count = 0
        var endIndex = input.startIndex

        while endIndex < input.endIndex {
            if count >= maxLength {
                break
            }
            guard predicate(input[endIndex]) else {
                break
            }
            input.formIndex(after: &endIndex)
            count += 1
        }

        guard count >= minLength else {
            throw .countTooLow(expected: minLength, got: count)
        }

        let result = input[input.startIndex..<endIndex]
        input = input[endIndex...]
        return result
    }
}

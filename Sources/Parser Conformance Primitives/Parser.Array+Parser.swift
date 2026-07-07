//
//  Parser.Array+Parser.swift
//  swift-standards
//
//  Array conformance to Parser and Printer for literal usage.
//

extension Swift.Array: Parser.`Protocol` where Element: Equatable {
    /// The input type this parser consumes: an array slice.
    public typealias Input = ArraySlice<Element>
    /// This parser produces no value; it matches the literal sequence.
    public typealias Output = Void
    /// The error type this parser can throw when the elements do not match.
    public typealias Failure = Parser.Match.Error

    /// Matches this array as a literal prefix of the input, consuming it on success.
    @inlinable
    public func parse(_ input: inout ArraySlice<Element>) throws(Failure) {
        for expected in self {
            guard let actual = input.first else {
                throw .literalMismatch(expected: "\(expected)", found: "end of input")
            }
            guard actual == expected else {
                throw .literalMismatch(expected: "\(expected)", found: "\(actual)")
            }
            input = input.dropFirst()
        }
    }
}

extension Swift.Array: Parser.Printer where Element: Equatable {
    /// Prints this array by inserting its elements at the front of the input.
    @inlinable
    public func print(_ output: Void, into input: inout ArraySlice<Element>) {
        input.insert(contentsOf: self, at: input.startIndex)
    }
}

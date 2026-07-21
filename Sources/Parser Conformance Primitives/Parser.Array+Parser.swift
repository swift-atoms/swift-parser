//
//  Parser.Array+Parser.swift
//  swift-standards
//
//  Array conformance to Parser for literal usage.
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

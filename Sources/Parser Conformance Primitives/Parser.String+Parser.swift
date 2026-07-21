//
//  Parser.String+Parser.swift
//  swift-standards
//
//  String conformance to Parser for literal usage.
//

extension String: Parser.`Protocol` {
    /// The input type this parser consumes: a substring.
    public typealias Input = Substring
    /// This parser produces no value; it matches the literal.
    public typealias Output = Void
    /// The error type this parser can throw when the literal does not match.
    public typealias Failure = Parser.Match.Error

    /// Matches this string as a literal prefix of the input, consuming it on success.
    @inlinable
    public func parse(_ input: inout Substring) throws(Failure) {
        guard input.hasPrefix(self) else {
            throw .literalMismatch(expected: self, found: String(input.prefix(self.count)))
        }
        input = input.dropFirst(self.count)
    }
}

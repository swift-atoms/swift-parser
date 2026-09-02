public import Parser

extension String: Parser::Parser.`Protocol` {

    public typealias Input = Substring

    public typealias Output = Void

    public typealias Failure = Parser::Parser.Literal.Error

    @inlinable
    public func parse(_ input: inout Substring) throws(Failure) {
        guard input.hasPrefix(self) else {
            throw .mismatch(expected: self, found: String(input.prefix(self.count)))
        }
        input = input.dropFirst(self.count)
    }
}

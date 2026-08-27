extension String: Parser.`Protocol` {

    public typealias Input = Substring

    public typealias Output = Void

    public typealias Failure = Parser.Match.Error

    @inlinable
    public func parse(_ input: inout Substring) throws(Failure) {
        guard input.hasPrefix(self) else {
            throw .literalMismatch(expected: self, found: String(input.prefix(self.count)))
        }
        input = input.dropFirst(self.count)
    }
}

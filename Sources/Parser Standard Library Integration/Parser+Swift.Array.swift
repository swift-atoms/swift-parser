public import Parser

extension Swift.Array: Parser::Parser.`Protocol` where Element: Equatable {

    public typealias Input = ArraySlice<Element>

    public typealias Output = Void

    public typealias Failure = Parser::Parser.Literal.Error

    @inlinable
    public func parse(_ input: inout ArraySlice<Element>) throws(Failure) {
        for expected in self {
            guard let actual = input.first else {
                throw .mismatch(expected: "\(expected)", found: "end of input")
            }
            guard actual == expected else {
                throw .mismatch(expected: "\(expected)", found: "\(actual)")
            }
            input = input.dropFirst()
        }
    }
}

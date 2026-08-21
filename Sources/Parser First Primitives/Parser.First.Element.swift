public import Input_Primitives

extension Parser.First {

    public struct Element<Input: Input_Primitives.Input.Streaming>
    where Input.Element: Copyable {

        @inlinable
        public init() {}
    }
}

extension Parser.First.Element: Parser.`Protocol` {

    public typealias Output = Input.Element

    public typealias Failure = Parser.EndOfInput.Error

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        guard !input.isEmpty else {
            throw .unexpected(expected: "any element")
        }

        return try! input.advance()
    }
}

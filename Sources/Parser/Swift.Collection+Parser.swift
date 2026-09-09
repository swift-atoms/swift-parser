extension Swift.Collection where Element: Equatable {
    /// Interprets this collection as an exact prefix literal, not as a value to decode.
    /// The slice retains this collection without materializing an array.
    @inlinable
    public func parser<Input: Swift.Collection>(
        for input: Input.Type = Input.self
    ) -> Swift.Slice<Self>.Parser<Input>
    where Input.SubSequence == Input, Input.Element == Element {
        .init(Swift.Slice(base: self, bounds: startIndex..<endIndex))
    }
}

extension Parser::Builder
where Input: Swift.Collection, Input.SubSequence == Input, Input.Element: Equatable {
    @inlinable
    public static func buildExpression<Literal: Swift.Collection>(
        _ literal: Literal
    ) -> Swift.Slice<Literal>.Parser<Input>
    where Literal.Element == Input.Element {
        literal.parser(for: Input.self)
    }
}

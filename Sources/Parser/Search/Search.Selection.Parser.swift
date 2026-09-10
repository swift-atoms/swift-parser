#if Search
public import Search

extension Search.Selection where Pattern: Swift.Collection, Pattern.Element: Equatable {

    public struct Parser<Input: Swift.Collection>: Parser::Parsing
    where Input.SubSequence == Input, Input.Element == Pattern.Element {
        public typealias Output = Input
        public typealias Failure = Search<Pattern>.Error
        public let wrapped: Search<Pattern>.Selection

        public init(_ wrapped: Search<Pattern>.Selection) { self.wrapped = wrapped }

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Input {
            let end = try wrapped.end(
                from: input.startIndex,
                advance: { position in
                    position == input.endIndex ? nil : input.index(after: position)
                },
                matching: { delimiter, position in
                    var end = position
                    for element in delimiter {
                        guard end != input.endIndex, input[end] == element else { return nil }
                        input.formIndex(after: &end)
                    }
                    return end
                }
            )
            let output = input[..<end]
            input = input[end...]
            return output
        }
    }

    public func parser<Input: Swift.Collection>(for input: Input.Type) -> Parser<Input>
    where Input.SubSequence == Input, Input.Element == Pattern.Element {
        .init(self)
    }

}

extension Parser::Builder where Input: Swift.Collection, Input.SubSequence == Input {
    public static func buildExpression<D: Swift.Collection>(_ selection: Search<D>.Selection) -> Search<D>.Selection.Parser<Input>
    where D.Element: Equatable, D.Element == Input.Element {
        .init(selection)
    }
}

#endif

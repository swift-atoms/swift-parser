extension Swift.ArraySlice where Element: Equatable {

    public struct Parser<Input: Swift.Collection>: Parser::Parsing
    where Input.SubSequence == Input, Input.Element == Element {
        public typealias Output = Void
        public typealias Failure = Error

        public typealias Error = Swift.Slice<Swift.ArraySlice<Element>>.Parser<Input>.Error

        public let wrapped: Swift.ArraySlice<Element>

        @inlinable
        public init(_ wrapped: Swift.ArraySlice<Element>) {
            self.wrapped = wrapped
        }

        @inlinable
        public borrowing func parse(_ input: inout Input) throws(Error) {
            try wrapped.parser(for: Input.self).parse(&input)
        }
    }
}

extension Parser::Builder
where Input: Swift.Collection, Input.SubSequence == Input, Input.Element: Equatable {
    @inlinable
    public static func buildExpression(_ literal: Swift.ArraySlice<Input.Element>) -> Swift.ArraySlice<Input.Element>.Parser<Input> {
        .init(literal)
    }
}

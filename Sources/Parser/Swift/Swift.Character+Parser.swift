extension Swift.Character {
    /// Matches the supplied literal without consuming input on failure.
    public struct Parser: Parser::Parsing {
        public typealias Input = Substring
        public typealias Output = Void
        public typealias Failure = Error

        public typealias Error = Swift.Slice<Swift.CollectionOfOne<Swift.Character>>.Parser<Input>.Error

        public let wrapped: Swift.Character

        @inlinable
        public init(_ wrapped: Swift.Character) {
            self.wrapped = wrapped
        }

        @inlinable
        public borrowing func parse(_ input: inout Substring) throws(Error) {
            try Swift.CollectionOfOne(wrapped).parser(for: Input.self).parse(&input)
        }
    }
}

extension Parser::Builder where Input == Substring {
    @inlinable
    public static func buildExpression(_ literal: Swift.Character) -> Swift.Character.Parser {
        .init(literal)
    }
}

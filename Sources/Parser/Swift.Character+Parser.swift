extension Swift.Character {
    /// Matches the supplied literal without consuming input on failure.
    public struct Parser: Parser::Parsing {
        public typealias Input = Substring
        public typealias Output = Void
        public typealias Failure = Error

        public enum Error: Swift.Error, Equatable { case mismatch }

        public let wrapped: Swift.Character

        @inlinable
        public init(_ wrapped: Swift.Character) {
            self.wrapped = wrapped
        }

        @inlinable
        public borrowing func parse(_ input: inout Substring) throws(Error) {
            guard matchPrefix(Swift.CollectionOfOne(wrapped), in: &input) else { throw .mismatch }
        }
    }
}

extension Parser::Builder where Input == Substring {
    @inlinable
    public static func buildExpression(_ literal: Swift.Character) -> Swift.Character.Parser {
        .init(literal)
    }
}

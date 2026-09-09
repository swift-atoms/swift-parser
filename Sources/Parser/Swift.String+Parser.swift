extension Swift.String {
    /// Matches the supplied literal without consuming input on failure.
    public struct Parser: Parser::Parsing {
        public typealias Input = Substring
        public typealias Output = Void
        public typealias Failure = Error

        public enum Error: Swift.Error, Equatable { case mismatch }

        public let wrapped: Swift.String

        @inlinable
        public init(_ wrapped: Swift.String) {
            self.wrapped = wrapped
        }

        @inlinable
        public borrowing func parse(_ input: inout Substring) throws(Error) {
            guard matchPrefix(wrapped, in: &input) else { throw .mismatch }
        }
    }
}

extension Parser::Builder where Input == Substring {
    @inlinable
    public static func buildExpression(_ literal: Swift.String) -> Swift.String.Parser {
        .init(literal)
    }
}

extension Swift.Optional
where
    Wrapped: Parser::Parsing,
    Wrapped.Input: ~Copyable & ~Escapable,
    Wrapped.Output: ~Copyable & Escapable
{

    public struct Parser: Parser::Parsing {

        public typealias Input = Wrapped.Input

        public typealias Output = Wrapped.Output?

        public typealias Failure = Wrapped.Failure

        public let wrapped: Swift.Optional<Wrapped>

        @inlinable
        public init(_ wrapped: Swift.Optional<Wrapped>) {
            self.wrapped = wrapped
        }

        @inlinable
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            guard let wrapped else {
                return nil
            }
            return try wrapped.parse(&input)
        }
    }
}

extension Parser::Builder where Input: ~Copyable & ~Escapable {

    @inlinable
    public static func buildIf<P: Parser::Parsing>(
        _ parser: P?
    ) -> Swift.Optional<P>.Parser
    where
        P.Input == Input,
        P.Input: ~Copyable & ~Escapable,
        P.Output: ~Copyable & Escapable
    {
        .init(parser)
    }
}

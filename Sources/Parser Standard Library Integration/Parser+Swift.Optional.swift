public import Parser

extension Swift.Optional
where
    Wrapped: Parser::Parser.`Protocol`,
    Wrapped.Input: ~Copyable & ~Escapable,
    Wrapped.Output: ~Copyable & ~Escapable
{

    public struct Parser {

        public let wrapped: Swift.Optional<Wrapped>

        @inlinable
        public init(_ wrapped: Swift.Optional<Wrapped>) {
            self.wrapped = wrapped
        }
    }
}

extension Swift.Optional.Parser: Parser::Parser.`Protocol`
where
    Wrapped.Input: ~Copyable & ~Escapable,
    Wrapped.Output: Escapable
{

    public typealias Input = Wrapped.Input

    public typealias Output = Wrapped.Output?

    public typealias Failure = Wrapped.Failure

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        guard let wrapped else {
            return nil
        }
        return try wrapped.parse(&input)
    }
}

extension Parser::Parser.Builder where Input: ~Copyable & ~Escapable {

    @inlinable
    public static func buildIf<P: Parser::Parser.`Protocol`>(
        _ parser: P?
    ) -> Swift.Optional<P>.Parser
    where
        P.Input == Input,
        P.Input: ~Copyable & ~Escapable,
        P.Output: Escapable
    {
        .init(parser)
    }
}

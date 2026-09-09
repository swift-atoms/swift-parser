public import Either

extension Parser.Builder where Input: ~Copyable & ~Escapable {

    @inlinable
    public static func buildPartialBlock<A: Parser.`Protocol` & ~Copyable, N: Parser.`Protocol` & ~Copyable, each O>(
        accumulated: consuming A,
        next: consuming N
    ) -> Parser::Skip<A.Output, N.Output>.Parser<A, N, Either<A.Failure, N.Failure>>
    where
        A.Input == Input,
        N.Input == Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output == (repeat each O),
        N.Output == Void
    {
        Parser::Skip.Parser(accumulated, next, { .left($0) }, { .right($0) })
    }

    @inlinable
    public static func buildPartialBlock<A: Parser.`Protocol` & ~Copyable, N: Parser.`Protocol` & ~Copyable, each O>(
        accumulated: consuming A,
        next: consuming N
    ) -> Parser::Skip<A.Output, N.Output>.Parser<A, N, A.Failure>
    where
        A.Input == Input,
        N.Input == Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output == (repeat each O),
        N.Output == Void,
        A.Failure == N.Failure
    {
        Parser::Skip.Parser(accumulated, next, { $0 }, { $0 })
    }
}

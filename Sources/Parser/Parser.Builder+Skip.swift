public import Either

extension Parser.Builder where Input: ~Copyable & ~Escapable {

    @inlinable
    public static func buildPartialBlock<A: Parser.`Protocol`, N: Parser.`Protocol`, each O>(
        accumulated: A,
        next: N
    ) -> Parser.Skip<A, N, Either<A.Failure, N.Failure>>
    where
        A.Input == Input,
        N.Input == Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output == (repeat each O),
        N.Output == Void
    {
        Parser.Skip(accumulated, next, { .left($0) }, { .right($0) })
    }

    @inlinable
    public static func buildPartialBlock<A: Parser.`Protocol`, N: Parser.`Protocol`, each O>(
        accumulated: A,
        next: N
    ) -> Parser.Skip<A, N, A.Failure>
    where
        A.Input == Input,
        N.Input == Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output == (repeat each O),
        N.Output == Void,
        A.Failure == N.Failure
    {
        Parser.Skip(accumulated, next, { $0 }, { $0 })
    }
}

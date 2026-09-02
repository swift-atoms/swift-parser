public import Either
public import Parser

extension Parser.Builder where Input: ~Copyable & ~Escapable {

    @inlinable
    public static func buildPartialBlock<A: Parser.`Protocol`, N: Parser.`Protocol`, each O>(
        accumulated: A,
        next: N
    ) -> Parser.Append<A, N, Either<A.Failure, N.Failure>, repeat each O>
    where
        A.Input == Input,
        N.Input == Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output == (repeat each O)
    {
        Parser.Append(accumulated, next, { .left($0) }, { .right($0) })
    }

    @inlinable
    public static func buildPartialBlock<A: Parser.`Protocol`, N: Parser.`Protocol`, each O>(
        accumulated: A,
        next: N
    ) -> Parser.Append<A, N, A.Failure, repeat each O>
    where
        A.Input == Input,
        N.Input == Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output == (repeat each O),
        A.Failure == N.Failure
    {
        Parser.Append(accumulated, next, { $0 }, { $0 })
    }
}

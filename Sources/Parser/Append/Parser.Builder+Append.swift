#if Append
public import Append
public import Either

extension Parser::Builder where Input: ~Copyable & ~Escapable {

    @inlinable
    public static func buildPartialBlock<A: Parsing & ~Copyable, N: Parsing & ~Copyable, each O>(
        accumulated: consuming A,
        next: consuming N
    ) -> Append::Append<A.Output, N.Output, (repeat each O, N.Output), Never>.Parser<A, N, Either<A.Failure, N.Failure>>
    where
        A.Input == Input,
        N.Input == Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output == (repeat each O)
    {
        .init(
            .init(), accumulated, next,
            accumulatedFailure: { .left($0) },
            nextFailure: { .right($0) },
            appendFailure: { $0 }
        )
    }

    @inlinable
    public static func buildPartialBlock<A: Parsing & ~Copyable, N: Parsing & ~Copyable, each O>(
        accumulated: consuming A,
        next: consuming N
    ) -> Append::Append<A.Output, N.Output, (repeat each O, N.Output), Never>.Parser<A, N, A.Failure>
    where
        A.Input == Input,
        N.Input == Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output == (repeat each O),
        A.Failure == N.Failure
    {
        .init(
            .init(), accumulated, next,
            accumulatedFailure: { $0 },
            nextFailure: { $0 },
            appendFailure: { $0 }
        )
    }
}

#endif

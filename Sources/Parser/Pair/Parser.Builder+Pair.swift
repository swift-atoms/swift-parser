#if Pair

public import Either
public import Pair

extension Parser::Builder where Input: ~Copyable & ~Escapable {

    @_disfavoredOverload
    @inlinable
    public static func buildPartialBlock<A: Parser::Parsing & ~Copyable, N: Parser::Parsing & ~Copyable>(
        accumulated: consuming A,
        next: consuming N
    ) -> Pair::Pair<A, N>.Parser<Either<A.Failure, N.Failure>>
    where
        A.Input == Input,
        N.Input == Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output: ~Copyable & Escapable,
        N.Output: ~Copyable & Escapable
    {
        .init(accumulated, next, { .left($0) }, { .right($0) })
    }

    @_disfavoredOverload
    @inlinable
    public static func buildPartialBlock<A: Parser::Parsing & ~Copyable, N: Parser::Parsing & ~Copyable>(
        accumulated: consuming A,
        next: consuming N
    ) -> Pair::Pair<A, N>.Parser<A.Failure>
    where
        A.Input == Input,
        N.Input == Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output: ~Copyable & Escapable,
        N.Output: ~Copyable & Escapable,
        A.Failure == N.Failure
    {
        .init(accumulated, next, { $0 }, { $0 })
    }
}

#endif

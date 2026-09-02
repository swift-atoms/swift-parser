public import Either
import Pair
public import Parser

extension Parser.Builder where Input: ~Copyable & ~Escapable {

    @inlinable
    public static func buildPartialBlock<A: Parser.`Protocol`, N: Parser.`Protocol`>(
        accumulated: A,
        next: N
    ) -> Parser.Product<A, N, Either<A.Failure, N.Failure>>
    where
        A.Input == Input,
        N.Input == Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output: ~Copyable & Escapable,
        N.Output: ~Copyable & Escapable
    {
        Parser.Product(accumulated, next, { .left($0) }, { .right($0) })
    }

    @inlinable
    public static func buildPartialBlock<A: Parser.`Protocol`, N: Parser.`Protocol`>(
        accumulated: A,
        next: N
    ) -> Parser.Product<A, N, A.Failure>
    where
        A.Input == Input,
        N.Input == Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output: ~Copyable & Escapable,
        N.Output: ~Copyable & Escapable,
        A.Failure == N.Failure
    {
        Parser.Product(accumulated, next, { $0 }, { $0 })
    }
}

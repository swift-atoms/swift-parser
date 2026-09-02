public import Either
public import Parser

extension Parser.Builder where Input: ~Copyable & ~Escapable {

    @inlinable
    public static func buildPartialBlock<A: Parser.`Protocol`, N: Parser.`Protocol`>(
        accumulated: A,
        next: N
    ) -> Parser.Skip.First<A, N, Either<A.Failure, N.Failure>>
    where
        A.Input == Input,
        N.Input == Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output == Void,
        N.Output: ~Copyable & ~Escapable
    {
        Parser.Skip.First(accumulated, next, { .left($0) }, { .right($0) })
    }

    @inlinable
    public static func buildPartialBlock<A: Parser.`Protocol`, N: Parser.`Protocol`>(
        accumulated: A,
        next: N
    ) -> Parser.Skip.First<A, N, A.Failure>
    where
        A.Input == Input,
        N.Input == Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output == Void,
        N.Output: ~Copyable & ~Escapable,
        A.Failure == N.Failure
    {
        Parser.Skip.First(accumulated, next, { $0 }, { $0 })
    }

    @inlinable
    public static func buildPartialBlock<A: Parser.`Protocol`, N: Parser.`Protocol`>(
        accumulated: A,
        next: N
    ) -> Parser.Skip.Second<A, N, Either<A.Failure, N.Failure>>
    where
        A.Input == Input,
        N.Input == Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output: ~Copyable & Escapable,
        N.Output == Void
    {
        Parser.Skip.Second(accumulated, next, { .left($0) }, { .right($0) })
    }

    @inlinable
    public static func buildPartialBlock<A: Parser.`Protocol`, N: Parser.`Protocol`>(
        accumulated: A,
        next: N
    ) -> Parser.Skip.Second<A, N, A.Failure>
    where
        A.Input == Input,
        N.Input == Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output: ~Copyable & Escapable,
        N.Output == Void,
        A.Failure == N.Failure
    {
        Parser.Skip.Second(accumulated, next, { $0 }, { $0 })
    }

    @inlinable
    public static func buildPartialBlock<A: Parser.`Protocol`, N: Parser.`Protocol`>(
        accumulated: A,
        next: N
    ) -> Parser.Skip.First<A, N, Either<A.Failure, N.Failure>>
    where
        A.Input == Input,
        N.Input == Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output == Void,
        N.Output == Void
    {
        Parser.Skip.First(accumulated, next, { .left($0) }, { .right($0) })
    }

    @inlinable
    public static func buildPartialBlock<A: Parser.`Protocol`, N: Parser.`Protocol`>(
        accumulated: A,
        next: N
    ) -> Parser.Skip.First<A, N, A.Failure>
    where
        A.Input == Input,
        N.Input == Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output == Void,
        N.Output == Void,
        A.Failure == N.Failure
    {
        Parser.Skip.First(accumulated, next, { $0 }, { $0 })
    }

    @inlinable
    public static func buildPartialBlock<A: Parser.`Protocol`, N: Parser.`Protocol`>(
        accumulated: A,
        next: N
    ) -> Parser.Skip.First<A, N, Either<A.Failure, N.Failure>>
    where
        A.Input == Input,
        N.Input == Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output == Void,
        N.Output: ~Copyable & Escapable
    {
        Parser.Skip.First(accumulated, next, { .left($0) }, { .right($0) })
    }

    @inlinable
    public static func buildPartialBlock<A: Parser.`Protocol`, N: Parser.`Protocol`>(
        accumulated: A,
        next: N
    ) -> Parser.Skip.First<A, N, A.Failure>
    where
        A.Input == Input,
        N.Input == Input,
        A.Input: ~Copyable & ~Escapable,
        N.Input: ~Copyable & ~Escapable,
        A.Output == Void,
        N.Output: ~Copyable & Escapable,
        A.Failure == N.Failure
    {
        Parser.Skip.First(accumulated, next, { $0 }, { $0 })
    }
}

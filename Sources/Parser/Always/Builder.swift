#if Always
    public import Parser_Core
    public import Always

    extension Parser::Builder {

        @inlinable
        public static func buildBlock() -> Always::Always<Void>.Parser<Input> {
            Always::Always(()).parser()
        }
    }

#endif

#if Append
    public import Parser_Core
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
                .init(),
                accumulated,
                next,
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
                .init(),
                accumulated,
                next,
                accumulatedFailure: { $0 },
                nextFailure: { $0 },
                appendFailure: { $0 }
            )
        }
    }

#endif

#if Either
    public import Parser_Core
    public import Either

    extension Parser::Builder where Input: ~Copyable & ~Escapable {
        @inlinable
        public static func buildExpression<L: Parser::Parsing & ~Copyable, R: Parser::Parsing & ~Copyable>(
            _ either: consuming Either<L, R>
        ) -> Either<L, R>.Parser
        where
            L.Input == Input,
            R.Input == Input,
            L.Output == R.Output,
            L.Input: ~Copyable & ~Escapable,
            R.Input: ~Copyable & ~Escapable,
            L.Output: ~Copyable & ~Escapable,
            R.Output: ~Copyable & ~Escapable
        {
            .init(either)
        }

        @inlinable
        public static func buildEither<
            First: Parser::Parsing & ~Copyable,
            Second: Parser::Parsing & ~Copyable
        >(
            first: consuming First
        ) -> Either<First, Second>.Parser
        where
            First.Input == Input,
            Second.Input == Input,
            First.Input: ~Copyable & ~Escapable,
            Second.Input: ~Copyable & ~Escapable,
            First.Output == Second.Output,
            First.Output: ~Copyable & ~Escapable,
            Second.Output: ~Copyable & ~Escapable
        {
            .init(.left(first))
        }

        @inlinable
        public static func buildEither<
            First: Parser::Parsing & ~Copyable,
            Second: Parser::Parsing & ~Copyable
        >(
            second: consuming Second
        ) -> Either<First, Second>.Parser
        where
            First.Input == Input,
            Second.Input == Input,
            First.Input: ~Copyable & ~Escapable,
            Second.Input: ~Copyable & ~Escapable,
            First.Output == Second.Output,
            First.Output: ~Copyable & ~Escapable,
            Second.Output: ~Copyable & ~Escapable
        {
            .init(.right(second))
        }
    }

#endif

#if Lazy
    public import Parser_Core
    public import Lazy
    public import Either

    extension Parser::Builder where Input: ~Copyable & ~Escapable {
        @inlinable
        public static func buildExpression<P: Parser::Parsing & ~Copyable>(
            _ lazy: Lazy::Lazy<P, Never>
        ) -> Lazy::Lazy<P, Never>.Parser<P.Failure>
        where
            P.Input == Input,
            P.Input: ~Copyable & ~Escapable,
            P.Output: ~Copyable & Escapable
        {
            .init(lazy)
        }

        @inlinable
        public static func buildExpression<P: Parser::Parsing & ~Copyable, F: Swift::Error>(
            _ lazy: Lazy::Lazy<P, F>
        ) -> Lazy::Lazy<P, F>.Parser<Either<F, P.Failure>>
        where
            P.Input == Input,
            P.Input: ~Copyable & ~Escapable,
            P.Output: ~Copyable & Escapable
        {
            .init(lazy)
        }
    }
#endif

#if Pair
    public import Parser_Core

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

#if Skip
    public import Parser_Core
    public import Skip
    public import Either

    extension Parser::Builder where Input: ~Copyable & ~Escapable {

        @inlinable
        public static func buildPartialBlock<A: Parsing & ~Copyable, N: Parsing & ~Copyable, each O>(
            accumulated: consuming A,
            next: consuming N
        ) -> Skip::Skip<A.Output, N.Output>.Parser<A, N, Either<A.Failure, N.Failure>>
        where
            A.Input == Input,
            N.Input == Input,
            A.Input: ~Copyable & ~Escapable,
            N.Input: ~Copyable & ~Escapable,
            A.Output == (repeat each O),
            N.Output == Void
        {
            Skip::Skip.Parser(accumulated, next, { .left($0) }, { .right($0) })
        }

        @inlinable
        public static func buildPartialBlock<A: Parsing & ~Copyable, N: Parsing & ~Copyable, each O>(
            accumulated: consuming A,
            next: consuming N
        ) -> Skip::Skip<A.Output, N.Output>.Parser<A, N, A.Failure>
        where
            A.Input == Input,
            N.Input == Input,
            A.Input: ~Copyable & ~Escapable,
            N.Input: ~Copyable & ~Escapable,
            A.Output == (repeat each O),
            N.Output == Void,
            A.Failure == N.Failure
        {
            Skip::Skip.Parser(accumulated, next, { $0 }, { $0 })
        }
    }

#endif

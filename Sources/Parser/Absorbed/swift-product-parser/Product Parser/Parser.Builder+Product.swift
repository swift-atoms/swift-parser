#if Product
#if hasFeature(MoveOnlyTuples) && hasFeature(NoncopyablePacks)
    public import Either

    public import Product

    extension Product::Product.Parser
    where Failure == Never, repeat each Element: ~Copyable {

        @usableFromInline
        @inlinable
        internal consuming func appending<
            Next: Parser::Parsing & ~Copyable
        >(
            _ next: consuming Next
        ) -> Product::Product<repeat each Element, Next>.Parser<Input, Never>
        where
            Next.Input == Input,
            Next.Output: Escapable,
            Next.Failure == Never
        {
            .init(
                upstream: Product::Product<repeat each Element, Next>(
                    repeat each upstream.values,
                    next
                ),
                failure: Product::Product<
                    repeat ((each Element).Failure) -> Never,
                    (Never) -> Never
                >(
                    repeat each failure.values,
                    { $0 }
                )
            )
        }

        @_disfavoredOverload
        @usableFromInline
        @inlinable
        internal consuming func appending<
            Next: Parser::Parsing & ~Copyable
        >(
            _ next: consuming Next
        ) -> Product::Product<repeat each Element, Next>.Parser<
            Input,
            Next.Failure
        >
        where Next.Input == Input, Next.Output: Escapable {
            .init(
                upstream: Product::Product<repeat each Element, Next>(
                    repeat each upstream.values,
                    next
                ),
                failure: Product::Product<
                    repeat ((each Element).Failure) -> Next.Failure,
                    (Next.Failure) -> Next.Failure
                >(
                    repeat { (each failure.values)($0) },
                    { $0 }
                )
            )
        }
    }

    extension Product::Product.Parser where repeat each Element: ~Copyable {

        @_disfavoredOverload
        @usableFromInline
        @inlinable
        internal consuming func appending<
            Next: Parser::Parsing & ~Copyable
        >(
            _ next: consuming Next
        ) -> Product::Product<repeat each Element, Next>.Parser<Input, Failure>
        where
            Next.Input == Input,
            Next.Output: Escapable,
            Next.Failure == Never
        {
            .init(
                upstream: Product::Product<repeat each Element, Next>(
                    repeat each upstream.values,
                    next
                ),
                failure: Product::Product<
                    repeat ((each Element).Failure) -> Failure,
                    (Never) -> Failure
                >(
                    repeat each failure.values,
                    { $0 }
                )
            )
        }

        @_disfavoredOverload
        @usableFromInline
        @inlinable
        internal consuming func appending<
            Next: Parser::Parsing & ~Copyable
        >(
            _ next: consuming Next
        ) -> Product::Product<repeat each Element, Next>.Parser<
            Input,
            Either<Failure, Next.Failure>
        >
        where Next.Input == Input, Next.Output: Escapable {
            .init(
                upstream: Product::Product<repeat each Element, Next>(
                    repeat each upstream.values,
                    next
                ),
                failure: Product::Product<
                    repeat ((each Element).Failure) -> Either<Failure, Next.Failure>,
                    (Next.Failure) -> Either<Failure, Next.Failure>
                >(
                    repeat { .left((each failure.values)($0)) },
                    { .right($0) }
                )
            )
        }
    }

    extension Parser::Builder {

        @_disfavoredOverload
        @inlinable
        public static func buildPartialBlock<
            First: Parser::Parsing,
            Second: Parser::Parsing
        >(
            accumulated first: First,
            next second: Second
        ) -> Product::Product<First, Second>.Parser<Input, Never>
        where
            First.Input == Input,
            Second.Input == Input,
            First.Output: Escapable,
            Second.Output: Escapable,
            First.Failure == Never,
            Second.Failure == Never
        {
            .init(
                upstream: Product::Product(first, second),
                failure: Product::Product(
                    { $0 } as (Never) -> Never,
                    { $0 } as (Never) -> Never
                )
            )
        }

        @_disfavoredOverload
        @inlinable
        public static func buildPartialBlock<
            First: Parser::Parsing,
            Second: Parser::Parsing
        >(
            accumulated first: First,
            next second: Second
        ) -> Product::Product<First, Second>.Parser<Input, Second.Failure>
        where
            First.Input == Input,
            Second.Input == Input,
            First.Output: Escapable,
            Second.Output: Escapable,
            First.Failure == Never
        {
            .init(
                upstream: Product::Product(first, second),
                failure: Product::Product(
                    { $0 } as (Never) -> Second.Failure,
                    { $0 }
                )
            )
        }

        @_disfavoredOverload
        @inlinable
        public static func buildPartialBlock<
            First: Parser::Parsing,
            Second: Parser::Parsing
        >(
            accumulated first: First,
            next second: Second
        ) -> Product::Product<First, Second>.Parser<Input, First.Failure>
        where
            First.Input == Input,
            Second.Input == Input,
            First.Output: Escapable,
            Second.Output: Escapable,
            Second.Failure == Never
        {
            .init(
                upstream: Product::Product(first, second),
                failure: Product::Product(
                    { $0 },
                    { $0 } as (Never) -> First.Failure
                )
            )
        }

        @_disfavoredOverload
        @inlinable
        public static func buildPartialBlock<
            First: Parser::Parsing,
            Second: Parser::Parsing
        >(
            accumulated first: First,
            next second: Second
        ) -> Product::Product<First, Second>.Parser<
            Input,
            Either<First.Failure, Second.Failure>
        >
        where
            First.Input == Input,
            Second.Input == Input,
            First.Output: Escapable,
            Second.Output: Escapable
        {
            .init(
                upstream: Product::Product(first, second),
                failure: Product::Product(
                    { .left($0) },
                    { .right($0) }
                )
            )
        }

        @_disfavoredOverload
        @inlinable
        public static func buildPartialBlock<
            each Element: Parser::Parsing & ~Copyable,
            Next: Parser::Parsing
        >(
            accumulated: consuming Product::Product<
                repeat each Element
            >.Parser<Input, Never>,
            next: consuming Next
        ) -> Product::Product<repeat each Element, Next>.Parser<Input, Never>
        where
            repeat (each Element).Input == Input,
            repeat (each Element).Output: Escapable,
            Next.Input == Input,
            Next.Output: Escapable,
            Next.Failure == Never
        {
            accumulated.appending(next)
        }

        @_disfavoredOverload
        @inlinable
        public static func buildPartialBlock<
            each Element: Parser::Parsing & ~Copyable,
            Next: Parser::Parsing
        >(
            accumulated: consuming Product::Product<
                repeat each Element
            >.Parser<Input, Never>,
            next: consuming Next
        ) -> Product::Product<repeat each Element, Next>.Parser<
            Input,
            Next.Failure
        >
        where
            repeat (each Element).Input == Input,
            repeat (each Element).Output: Escapable,
            Next.Input == Input,
            Next.Output: Escapable
        {
            accumulated.appending(next)
        }

        @_disfavoredOverload
        @inlinable
        public static func buildPartialBlock<
            each Element: Parser::Parsing & ~Copyable,
            Failure: Swift.Error,
            Next: Parser::Parsing
        >(
            accumulated: consuming Product::Product<
                repeat each Element
            >.Parser<Input, Failure>,
            next: consuming Next
        ) -> Product::Product<repeat each Element, Next>.Parser<Input, Failure>
        where
            repeat (each Element).Input == Input,
            repeat (each Element).Output: Escapable,
            Next.Input == Input,
            Next.Output: Escapable,
            Next.Failure == Never
        {
            accumulated.appending(next)
        }

        @_disfavoredOverload
        @inlinable
        public static func buildPartialBlock<
            each Element: Parser::Parsing & ~Copyable,
            Failure: Swift.Error,
            Next: Parser::Parsing
        >(
            accumulated: consuming Product::Product<
                repeat each Element
            >.Parser<Input, Failure>,
            next: consuming Next
        ) -> Product::Product<repeat each Element, Next>.Parser<
            Input,
            Either<Failure, Next.Failure>
        >
        where
            repeat (each Element).Input == Input,
            repeat (each Element).Output: Escapable,
            Next.Input == Input,
            Next.Output: Escapable
        {
            accumulated.appending(next)
        }
    }
#endif
#endif

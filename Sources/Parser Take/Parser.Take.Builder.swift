extension Parser.Take {

    @resultBuilder
    public struct Builder<Input: ~Copyable & ~Escapable> {}
}

extension Parser.Take.Builder {

    @inlinable
    public static func buildBlock() -> Parser.Always<Input, Void> {
        Parser.Always(())
    }

    @inlinable
    public static func buildBlock<P: Parser.`Protocol`>(
        _ parser: P
    ) -> P where P.Input == Input {
        parser
    }
}

extension Parser.Take.Builder {

    @inlinable
    public static func buildBlock<P0: Parser.`Protocol`, P1: Parser.`Protocol`>(
        _ p0: P0,
        _ p1: P1
    ) -> Parser.Take.Two<P0, P1>
    where P0.Input == Input, P1.Input == Input {
        Parser.Take.Two(p0, p1)
    }

    @inlinable
    public static func buildBlock<P0: Parser.`Protocol`, P1: Parser.`Protocol`>(
        _ p0: P0,
        _ p1: P1
    ) -> Parser.Skip.First<P0, P1>
    where P0.Input == Input, P1.Input == Input, P0.Output == Void {
        Parser.Skip.First(p0, p1)
    }

    @inlinable
    public static func buildBlock<P0: Parser.`Protocol`, P1: Parser.`Protocol`>(
        _ p0: P0,
        _ p1: P1
    ) -> Parser.Skip.Second<P0, P1>
    where P0.Input == Input, P1.Input == Input, P1.Output == Void {
        Parser.Skip.Second(p0, p1)
    }
}

extension Parser.Take.Builder {

    @inlinable
    public static func buildPartialBlock<P: Parser.`Protocol`>(
        first: P
    ) -> P where P.Input == Input {
        first
    }

    @_disfavoredOverload
    @inlinable
    public static func buildPartialBlock<Accumulated: Parser.`Protocol`, Next: Parser.`Protocol`>(
        accumulated: Accumulated,
        next: Next
    ) -> Parser.Take.Two<Accumulated, Next>
    where Accumulated.Input == Input, Next.Input == Input {
        Parser.Take.Two(accumulated, next)
    }

    @inlinable
    public static func buildPartialBlock<
        Accumulated: Parser.`Protocol`,
        Next: Parser.`Protocol`,
        each O1,
        O2
    >(
        accumulated: Accumulated,
        next: Next
    ) -> Parser.Take.Two<Accumulated, Next>.Map<(repeat each O1, O2)>
    where
        Accumulated.Input == Input,
        Next.Input == Input,
        Accumulated.Output == (repeat each O1),
        Next.Output == O2
    {
        Parser.Take.Two(accumulated, next)
            .map { tuple, next in
                (repeat each tuple, next)
            }
    }

    @inlinable
    public static func buildPartialBlock<Accumulated: Parser.`Protocol`, Next: Parser.`Protocol`>(
        accumulated: Accumulated,
        next: Next
    ) -> Parser.Skip.First<Accumulated, Next>
    where Accumulated.Input == Input, Next.Input == Input, Accumulated.Output == Void {
        Parser.Skip.First(accumulated, next)
    }

    @inlinable
    public static func buildPartialBlock<Accumulated: Parser.`Protocol`, Next: Parser.`Protocol`>(
        accumulated: Accumulated,
        next: Next
    ) -> Parser.Skip.Second<Accumulated, Next>
    where Accumulated.Input == Input, Next.Input == Input, Next.Output == Void {
        Parser.Skip.Second(accumulated, next)
    }
}

extension Parser.Take.Builder {

    @inlinable
    public static func buildIf<P: Parser.`Protocol`>(
        _ parser: P?
    ) -> Parser.Optional<P> where P.Input == Input {
        .init(parser)
    }

    @inlinable
    public static func buildEither<First: Parser.`Protocol`, Second: Parser.`Protocol`>(
        first: First
    ) -> Parser.Conditional<First, Second>
    where First.Input == Input, Second.Input == Input, First.Output == Second.Output {
        Parser.Conditional.first(first)
    }

    @inlinable
    public static func buildEither<First: Parser.`Protocol`, Second: Parser.`Protocol`>(
        second: Second
    ) -> Parser.Conditional<First, Second>
    where First.Input == Input, Second.Input == Input, First.Output == Second.Output {
        Parser.Conditional.second(second)
    }
}

extension Parser.Take.Builder {

    @inlinable
    public static func buildExpression<P: Parser.`Protocol`>(
        _ parser: P
    ) -> P where P.Input == Input {
        parser
    }
}

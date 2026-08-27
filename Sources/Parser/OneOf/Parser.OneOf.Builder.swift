extension Parser.OneOf {

    @resultBuilder
    public struct Builder<Input, Output> {}
}

extension Parser.OneOf.Builder {

    @inlinable
    public static func buildBlock<P: Parser.`Protocol`>(
        _ parser: P
    ) -> P where P.Input == Input, P.Output == Output {
        parser
    }

    @inlinable
    public static func buildBlock<P0: Parser.`Protocol`, P1: Parser.`Protocol`>(
        _ p0: P0,
        _ p1: P1
    ) -> Parser.OneOf.Two<P0, P1>
    where
        P0.Input == Input,
        P1.Input == Input,
        P0.Output == Output,
        P1.Output == Output
    {
        Parser.OneOf.Two(p0, p1)
    }

    @inlinable
    public static func buildBlock<
        P0: Parser.`Protocol`,
        P1: Parser.`Protocol`,
        P2: Parser.`Protocol`
    >(
        _ p0: P0,
        _ p1: P1,
        _ p2: P2
    ) -> Parser.OneOf.Three<P0, P1, P2>
    where
        P0.Input == Input,
        P1.Input == Input,
        P2.Input == Input,
        P0.Output == Output,
        P1.Output == Output,
        P2.Output == Output
    {
        Parser.OneOf.Three(p0, p1, p2)
    }

    @inlinable
    public static func buildPartialBlock<P: Parser.`Protocol`>(
        first: P
    ) -> P where P.Input == Input, P.Output == Output {
        first
    }

    @inlinable
    public static func buildPartialBlock<Accumulated: Parser.`Protocol`, Next: Parser.`Protocol`>(
        accumulated: Accumulated,
        next: Next
    ) -> Parser.OneOf.Two<Accumulated, Next>
    where
        Accumulated.Input == Input,
        Next.Input == Input,
        Accumulated.Output == Output,
        Next.Output == Output
    {
        Parser.OneOf.Two(accumulated, next)
    }
}

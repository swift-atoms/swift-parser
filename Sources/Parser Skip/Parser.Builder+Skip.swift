extension Parser.Builder {

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

    @inlinable
    public static func buildPartialBlock<Accumulated: Parser.`Protocol`, Next: Parser.`Protocol`>(
        accumulated: Accumulated,
        next: Next
    ) -> Parser.Skip.First<Accumulated, Next>
    where
        Accumulated.Input == Input,
        Next.Input == Input,
        Accumulated.Output == Void,
        Next.Output == Void
    {
        Parser.Skip.First(accumulated, next)
    }
}

extension Parser {

    @resultBuilder
    public struct Builder<Input: ~Copyable & ~Escapable> {}
}

extension Parser.Builder {

    @inlinable
    public static func buildExpression<P: Parser.`Protocol`>(
        _ parser: P
    ) -> P where P.Input == Input {
        parser
    }

    @inlinable
    public static func buildBlock<P: Parser.`Protocol`>(
        _ parser: P
    ) -> P where P.Input == Input {
        parser
    }

    @inlinable
    public static func buildPartialBlock<P: Parser.`Protocol`>(
        first: P
    ) -> P where P.Input == Input {
        first
    }
}

public import Either
public import Parser

extension Parser::Parser.Builder {

    @inlinable
    public static func buildEither<
        First: Parser::Parser.`Protocol` & Copyable,
        Second: Parser::Parser.`Protocol` & Copyable
    >(
        first: First
    ) -> Either<First, Second>
    where
        First.Input == Input,
        Second.Input == Input,
        First.Output == Second.Output,
        First.Output: Escapable
    {
        .left(first)
    }

    @inlinable
    public static func buildEither<
        First: Parser::Parser.`Protocol` & Copyable,
        Second: Parser::Parser.`Protocol` & Copyable
    >(
        second: Second
    ) -> Either<First, Second>
    where
        First.Input == Input,
        Second.Input == Input,
        First.Output == Second.Output,
        First.Output: Escapable
    {
        .right(second)
    }
}

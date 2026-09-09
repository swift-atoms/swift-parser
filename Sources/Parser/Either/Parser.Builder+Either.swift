#if Either
public import Either

extension Parser::Builder where Input: ~Copyable & ~Escapable {
    @inlinable
    public static func buildExpression<L: Parser::Parsing, R: Parser::Parsing>(
        _ either: Either<L, R>
    ) -> Either<L, R>.Parser
    where L.Input == Input, R.Input == Input, L.Output == R.Output,
          L.Input: ~Copyable & ~Escapable, R.Input: ~Copyable & ~Escapable,
          L.Output: ~Copyable & Escapable, R.Output: ~Copyable & Escapable {
        .init(either)
    }


    @inlinable
    public static func buildEither<
        First: Parser::Parsing & Copyable,
        Second: Parser::Parsing & Copyable
    >(
        first: First
    ) -> Either<First, Second>.Parser
    where
        First.Input == Input,
        Second.Input == Input,
        First.Input: ~Copyable & ~Escapable,
        Second.Input: ~Copyable & ~Escapable,
        First.Output == Second.Output,
        First.Output: ~Copyable & Escapable,
        Second.Output: ~Copyable & Escapable
    {
        .init(.left(first))
    }

    @inlinable
    public static func buildEither<
        First: Parser::Parsing & Copyable,
        Second: Parser::Parsing & Copyable
    >(
        second: Second
    ) -> Either<First, Second>.Parser
    where
        First.Input == Input,
        Second.Input == Input,
        First.Input: ~Copyable & ~Escapable,
        Second.Input: ~Copyable & ~Escapable,
        First.Output == Second.Output,
        First.Output: ~Copyable & Escapable,
        Second.Output: ~Copyable & Escapable
    {
        .init(.right(second))
    }
}

#endif

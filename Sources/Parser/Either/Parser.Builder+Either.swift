#if Either
public import Either

extension Parser::Builder where Input: ~Copyable & ~Escapable {

    @inlinable
    public static func buildEither<
        First: Parser::Parsing & Copyable,
        Second: Parser::Parsing & Copyable
    >(
        first: First
    ) -> Either<First, Second>
    where
        First.Input == Input,
        Second.Input == Input,
        First.Input: ~Copyable & ~Escapable,
        Second.Input: ~Copyable & ~Escapable,
        First.Output == Second.Output,
        First.Output: ~Copyable & Escapable,
        Second.Output: ~Copyable & Escapable
    {
        .left(first)
    }

    @inlinable
    public static func buildEither<
        First: Parser::Parsing & Copyable,
        Second: Parser::Parsing & Copyable
    >(
        second: Second
    ) -> Either<First, Second>
    where
        First.Input == Input,
        Second.Input == Input,
        First.Input: ~Copyable & ~Escapable,
        Second.Input: ~Copyable & ~Escapable,
        First.Output == Second.Output,
        First.Output: ~Copyable & Escapable,
        Second.Output: ~Copyable & Escapable
    {
        .right(second)
    }
}

#endif

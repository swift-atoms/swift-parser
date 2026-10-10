@resultBuilder
public struct Builder<Input: ~Copyable & ~Escapable> {}

extension Builder where Input: ~Copyable & ~Escapable {

    @inlinable
    public static func buildExpression<P: Parsing & ~Copyable>(
        _ parser: consuming P
    ) -> P
    where
        P.Input == Input,
        P.Input: ~Copyable & ~Escapable,
        P.Output: ~Copyable & ~Escapable
    {
        parser
    }

    @inlinable
    public static func buildBlock<P: Parsing & ~Copyable>(
        _ parser: consuming P
    ) -> P
    where
        P.Input == Input,
        P.Input: ~Copyable & ~Escapable,
        P.Output: ~Copyable & ~Escapable
    {
        parser
    }

    @inlinable
    public static func buildPartialBlock<P: Parsing & ~Copyable>(
        first: consuming P
    ) -> P
    where
        P.Input == Input,
        P.Input: ~Copyable & ~Escapable,
        P.Output: ~Copyable & ~Escapable
    {
        first
    }
}

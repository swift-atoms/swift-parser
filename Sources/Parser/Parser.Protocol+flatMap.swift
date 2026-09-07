import Either

extension Parser.`Protocol`
where
    Self: ~Copyable,
    Input: ~Copyable & ~Escapable,
    Output: ~Copyable & ~Escapable
{

    @inlinable
    public consuming func flatMap<P: Parser.`Protocol` & ~Copyable>(
        _ transform: @escaping (consuming Output) -> P
    ) -> Parser.FlatMap<Self, P>
    where
        P.Input == Input,
        P.Input: ~Copyable & ~Escapable,
        P.Output: ~Copyable & Escapable
    {
        .init(upstream: self, transform: transform)
    }

}

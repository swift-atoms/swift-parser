extension Parser.`Protocol`
where
    Input: ~Copyable & ~Escapable,
    Output: ~Copyable & ~Escapable
{

    @inlinable
    public func flatMap<P: Parser.`Protocol`>(
        _ transform: @escaping (consuming Output) -> P
    ) -> Parser.FlatMap<Self, P>
    where
        P.Input == Input,
        P.Input: ~Copyable & ~Escapable,
        P.Output: Escapable
    {
        .init(upstream: self, transform: transform)
    }

}

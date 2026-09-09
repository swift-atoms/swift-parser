#if FlatMap
public import FlatMap

extension Parsing
where
    Self: ~Copyable,
    Input: ~Copyable & ~Escapable,
    Output: ~Copyable & ~Escapable
{

    @inlinable
    public consuming func flatMap<P: Parsing & ~Copyable>(
        _ transform: @escaping (consuming Output) -> P
    ) -> FlatMap::FlatMap<Output, P>.Parser<Self>
    where
        P.Input == Input,
        P.Input: ~Copyable & ~Escapable,
        P.Output: ~Copyable & Escapable
    {
        .init(upstream: self, transform: transform)
    }
}

#endif

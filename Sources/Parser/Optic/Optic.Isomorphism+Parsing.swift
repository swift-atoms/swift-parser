#if Optic
public import Optic

extension Parser::Parsing
where
    Self: ~Copyable,
    Input: ~Copyable & ~Escapable,
    Output: ~Copyable & ~Escapable
{

    @inlinable
    public consuming func map<
        Source: ~Copyable & ~Escapable,
        Target: ~Copyable & Escapable,
        Focus: ~Copyable & Escapable,
        Replacement: ~Copyable & ~Escapable
    >(
        forward isomorphism: Optic::Optic<
            Source,
            Target,
            Focus,
            Replacement
        >.Isomorphism
    ) -> Map::Map<Self.Output, Focus, Failure>.Parser<Self>
    where Output == Source {
        map(isomorphism.forward)
    }
}

#endif

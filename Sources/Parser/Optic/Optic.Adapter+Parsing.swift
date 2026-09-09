#if Optic
public import Either
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
        Replacement: ~Copyable & ~Escapable,
        BackwardFailure: Swift.Error
    >(
        forward adapter: Optic::Optic<
            Source,
            Target,
            Focus,
            Replacement
        >.Adapter<Never, BackwardFailure>
    ) -> Map::Map<Self.Output, Focus, Never>.Parser<Self>
    where Output == Source, Failure == Never {
        map { source in adapter.forward(source) }
    }

    @inlinable
    public consuming func map<
        Source: ~Copyable & ~Escapable,
        Target: ~Copyable & Escapable,
        Focus: ~Copyable & Escapable,
        Replacement: ~Copyable & ~Escapable,
        BackwardFailure: Swift.Error
    >(
        forward adapter: Optic::Optic<
            Source,
            Target,
            Focus,
            Replacement
        >.Adapter<Never, BackwardFailure>
    ) -> Map::Map<Self.Output, Focus, Failure>.Parser<Self>
    where Output == Source {
        map { source in adapter.forward(source) }
    }

    @inlinable
    public consuming func map<
        Source: ~Copyable & ~Escapable,
        Target: ~Copyable & Escapable,
        Focus: ~Copyable & Escapable,
        Replacement: ~Copyable & ~Escapable,
        ForwardFailure: Swift.Error,
        BackwardFailure: Swift.Error
    >(
        forward adapter: Optic::Optic<
            Source,
            Target,
            Focus,
            Replacement
        >.Adapter<ForwardFailure, BackwardFailure>
    ) -> Map::Map<Self.Output, Focus, ForwardFailure>.Parser<Self>
    where Output == Source, Failure == Never {
        map(adapter.forward)
    }

    @_disfavoredOverload
    @inlinable
    public consuming func map<
        Source: ~Copyable & ~Escapable,
        Target: ~Copyable & Escapable,
        Focus: ~Copyable & Escapable,
        Replacement: ~Copyable & ~Escapable,
        ForwardFailure: Swift.Error,
        BackwardFailure: Swift.Error
    >(
        forward adapter: Optic::Optic<
            Source,
            Target,
            Focus,
            Replacement
        >.Adapter<ForwardFailure, BackwardFailure>
    ) -> Map::Map<Self.Output, Focus, Either<Failure, ForwardFailure>>.Parser<Self>
    where Output == Source {
        map(adapter.forward)
    }
}

#endif

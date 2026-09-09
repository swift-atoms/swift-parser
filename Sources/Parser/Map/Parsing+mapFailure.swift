#if Map
public import Map

extension Parsing
where
    Self: ~Copyable,
    Input: ~Copyable & ~Escapable,
    Output: ~Copyable & ~Escapable
{

    /// Transforms the failure type without changing successful outputs.
    @inlinable
    public consuming func mapFailure<NewFailure: Swift.Error>(
        _ transform: @escaping (Failure) -> NewFailure
    ) -> Map::Map<Failure, NewFailure, Never>.Error.Parser<Self> {
        Map::Map<Failure, NewFailure, Never>(transform).errorParser(self)
    }
}

#endif

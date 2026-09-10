#if Map
public import Map

extension Parsing
where
    Self: ~Copyable,
    Input: ~Copyable & ~Escapable,
    Output: ~Copyable & ~Escapable
{

    @inlinable
    public consuming func mapFailure<NewFailure: Swift.Error>(
        _ transform: @escaping (Failure) -> NewFailure
    ) -> Map::Map<Failure, NewFailure, Never>.Error.Parser<Self> {
        Map::Map<Failure, NewFailure, Never>(transform).errorParser(self)
    }
}

#endif

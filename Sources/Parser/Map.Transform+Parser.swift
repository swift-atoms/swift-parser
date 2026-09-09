extension Map.Transform
where Source: ~Copyable & ~Escapable, Target: ~Copyable & Escapable {
    @inlinable
    public func parser<P: Parsing & ~Copyable>(
        _ upstream: consuming P,
        failure: @escaping (P.Failure) -> Failure
    ) -> Map<P>.Parser<Target, Failure>
    where P.Input: ~Copyable & ~Escapable, P.Output: ~Copyable & ~Escapable,
        P.Output == Source {
        .init(self, upstream: upstream, failure: failure)
    }

    @inlinable
    public func parser<P: Parsing & ~Copyable>(
        _ upstream: consuming P
    ) -> Map<P>.Parser<Target, Failure>
    where P.Input: ~Copyable & ~Escapable, P.Output: ~Copyable & ~Escapable,
        P.Output == Source, P.Failure == Failure {
        .init(self, upstream: upstream, failure: { $0 })
    }
}

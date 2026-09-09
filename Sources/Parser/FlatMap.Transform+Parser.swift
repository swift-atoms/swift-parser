extension FlatMap.Transform
where Source: ~Copyable & ~Escapable,
    Continuation: Parsing & ~Copyable,
    Continuation.Input: ~Copyable & ~Escapable,
    Continuation.Output: ~Copyable & Escapable {
    @inlinable
    public func parser<P: Parsing & ~Copyable>(_ upstream: consuming P) -> FlatMap<P>.Parser<Continuation>
    where P.Input == Continuation.Input, P.Input: ~Copyable & ~Escapable,
        P.Output: ~Copyable & ~Escapable, P.Output == Source {
        .init(self, upstream: upstream)
    }
}

extension Parser.`Protocol` where Output: Copyable & Escapable {

    @inlinable
    public func filter(
        _ predicate: Predicate<Output>
    ) -> Parser.Filter<Self> {
        .init(upstream: self, predicate: predicate)
    }

    @inlinable
    public func filter(
        _ predicate: @escaping (Output) -> Bool
    ) -> Parser.Filter<Self> {
        .init(upstream: self, predicate: predicate)
    }
}

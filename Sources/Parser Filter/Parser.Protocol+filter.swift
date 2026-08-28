extension Parser.`Protocol` {

    @inlinable
    public func filter(
        _ predicate: @escaping (Output) -> Bool
    ) -> Parser.Filter<Self> {
        .init(upstream: self, predicate: predicate)
    }
}

extension Parser.`Protocol` {

    @inlinable
    public func map<NewOutput>(
        _ transform: @escaping (Output) -> NewOutput
    ) -> Parser.Map<Self, NewOutput> {
        .init(upstream: self, transform: transform)
    }

    @inlinable
    public func tryMap<NewOutput, E: Swift.Error>(
        _ transform: @escaping (Output) throws(E) -> NewOutput
    ) -> Parser.Map<Self, NewOutput>.Throwing<E> {
        .init(upstream: self, transform: transform)
    }
}

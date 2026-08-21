extension Parser.`Protocol` {

    @inlinable
    public func flatMap<P: Parser.`Protocol`>(
        _ transform: @escaping (Output) -> P
    ) -> Parser.FlatMap<Self, P>
    where P.Input == Input {
        .init(upstream: self, transform: transform)
    }

}

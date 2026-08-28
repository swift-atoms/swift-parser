extension Parser.`Protocol` {

    @inlinable
    public func flatMap<P: Parser.`Protocol`>(
        _ transform: @escaping (consuming Output) -> P
    ) -> Parser.FlatMap<Self, P>
    where P.Input == Input, P.Output: Escapable {
        .init(upstream: self, transform: transform)
    }

}

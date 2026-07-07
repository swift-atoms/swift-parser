extension Parser.`Protocol` {
    // `<P: Self>` would be invalid here: inside a `Parser.Protocol` extension
    // `Self` is the conforming type, not the protocol, so the generic bound must
    // name the protocol. (prefer_self_in_static_references generic-constraint FP.)
    // swiftlint:disable prefer_self_in_static_references
    /// Chains this parser with another that depends on its output.
    ///
    /// This is the monad `flatMap` operation for parsers.
    ///
    /// - Parameter transform: A function that produces a parser from this parser's output.
    /// - Returns: A parser that runs both parsers in sequence.
    @inlinable
    public func flatMap<P: Parser.`Protocol`>(
        _ transform: @escaping (Output) -> P
    ) -> Parser.FlatMap<Self, P>
    where P.Input == Input {
        .init(upstream: self, transform: transform)
    }
    // swiftlint:enable prefer_self_in_static_references
}

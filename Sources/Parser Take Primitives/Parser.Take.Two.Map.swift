//
//  Parser.Take.Two.Map.swift
//  swift-standards
//
//  Map transformation for Take.Two output.
//

extension Parser.Take.Two {
    /// A parser that transforms the output of a `Take.Two` parser.
    ///
    /// Used internally for tuple flattening with parameter packs: the
    /// `@Parser.Builder` variadic accumulator flattens `((repeat each O1), O2)`
    /// into `(repeat each O1, O2)` through this node (see
    /// `Parser.Builder+Take.swift`).
    ///
    /// ## Printing boundary (friction F2)
    ///
    /// `Take.Two.Map` is **parse-only** — it stores a one-way
    /// `(P0.Output, P1.Output) -> NewOutput` closure with no inverse, so it does
    /// **not** conform to `Serializer.Protocol` (swift-coder-primitives rows). A builder block that captures two
    /// or more non-`Void` values therefore flattens through this node and loses
    /// printability. This is not additively fixable: an opaque forward closure
    /// cannot be inverted, a `Printer` conformance cannot be made conditional on
    /// a value-level "has inverse" flag, and the variadic-flatten inverse
    /// (splitting the tail off a `(repeat each O1, O2)` pack) is not expressible
    /// with today's parameter packs.
    ///
    /// To retain printability for a multi-value grammar, compose the values
    /// through the bidirectional seam instead of the implicit builder flatten:
    /// build the pair(s) explicitly with ``Parser/Take/Two`` (which **is** a
    /// `Serializer.Protocol` (swift-coder-primitives rows) when its children are) and reshape the nested tuple
    /// with a ``Parser/Conversion/Protocol`` via `.map(conversion)` — e.g.
    /// ``Parser/Conversion/Memberwise`` or ``Parser/Conversion/Witness`` — which
    /// yields a ``Parser/Converted`` that stays `Parser.Bidirectional` (the Coder-based form in swift-coder-primitives). See the
    /// `Parser.Take.Two.Map Tests` round-trip for the covered multi-value shape.
    public struct Map<NewOutput> {
        @usableFromInline
        let upstream: Parser.Take.Two<P0, P1>

        @usableFromInline
        let transform: (P0.Output, P1.Output) -> NewOutput

        @inlinable
        package init(
            upstream: Parser.Take.Two<P0, P1>,
            transform: @escaping (P0.Output, P1.Output) -> NewOutput
        ) {
            self.upstream = upstream
            self.transform = transform
        }
    }
}

extension Parser.Take.Two.Map: Parser.`Protocol` {
    /// The input type this parser consumes.
    public typealias Input = P0.Input
    /// The output type this parser produces after transformation.
    public typealias Output = NewOutput
    /// The error type this parser can throw, inherited from the underlying pair.
    public typealias Failure = Parser.Take.Two<P0, P1>.Failure

    /// Parses the pair, then applies the transform to both outputs.
    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        let (o0, o1) = try upstream.parse(&input)
        return transform(o0, o1)
    }
}

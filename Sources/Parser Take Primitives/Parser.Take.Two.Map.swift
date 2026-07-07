//
//  Parser.Take.Two.Map.swift
//  swift-standards
//
//  Map transformation for Take.Two output.
//

extension Parser.Take.Two {
    /// A parser that transforms the output of a `Take.Two` parser.
    ///
    /// Used internally for tuple flattening with parameter packs.
    public struct Map<NewOutput> {
        @usableFromInline
        let upstream: Parser.Take.Two<P0, P1>

        @usableFromInline
        let transform: (P0.Output, P1.Output) -> NewOutput

        @inlinable
        init(
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

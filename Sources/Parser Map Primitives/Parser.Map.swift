//
//  Parser.Map.swift
//  swift-parser-primitives
//
//  Pure output transformation.
//

extension Parser {
    /// A parser that transforms the output of another parser.
    ///
    /// This is the functor `map` operation for parsers. It applies a pure
    /// transformation to successful parsing results.
    ///
    /// Created via `parser.map(_:)`.
    ///
    /// ## Throwing variant
    ///
    /// For transforms that may fail, see ``Parser/Map/Throwing``, created
    /// via `parser.tryMap(_:)`. The throwing variant inherits `Upstream`
    /// and `Output` from this type and adds a new error parameter `E`.
    public struct Map<Upstream: Parser.`Protocol`, Output> {
        @usableFromInline
        internal let upstream: Upstream

        @usableFromInline
        internal let transform: (Upstream.Output) -> Output

        /// Creates a map parser wrapping the upstream parser with an output transform.
        @inlinable
        public init(
            upstream: Upstream,
            transform: @escaping (Upstream.Output) -> Output
        ) {
            self.upstream = upstream
            self.transform = transform
        }
    }
}

extension Parser.Map: Parser.`Protocol` {
    /// The input type this parser consumes.
    public typealias Input = Upstream.Input
    /// The error type this parser can throw.
    public typealias Failure = Upstream.Failure

    /// Parses using the upstream parser, then applies the transform to its output.
    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        transform(try upstream.parse(&input))
    }
}

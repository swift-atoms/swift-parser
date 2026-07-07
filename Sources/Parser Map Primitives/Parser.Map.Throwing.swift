//
//  Parser.Map.Throwing.swift
//  swift-parser-primitives
//
//  Throwing output transformation.
//

public import Either_Primitives

extension Parser.Map {
    /// A parser that transforms output using a throwing function.
    ///
    /// If the transformation throws, parsing fails with that error.
    /// The resulting failure type is `Either<Upstream.Failure, E>`.
    ///
    /// Created via `parser.tryMap(_:)`.
    ///
    /// ## Shared generics
    ///
    /// `Upstream` and `Output` are inherited from the outer ``Parser/Map``
    /// type; only the error parameter `E` is added at this nesting level.
    public struct Throwing<E: Swift.Error> {
        @usableFromInline
        let upstream: Upstream

        @usableFromInline
        let transform: (Upstream.Output) throws(E) -> Output

        /// Creates a throwing-map parser wrapping the upstream parser with a throwing transform.
        @inlinable
        public init(
            upstream: Upstream,
            transform: @escaping (Upstream.Output) throws(E) -> Output
        ) {
            self.upstream = upstream
            self.transform = transform
        }
    }
}

extension Parser.Map.Throwing: Parser.`Protocol` {
    /// The input type this parser consumes.
    public typealias Input = Upstream.Input
    /// The error type this parser can throw, combining upstream and transform failures.
    public typealias Failure = Either<Upstream.Failure, E>

    /// Parses the upstream value, then applies the throwing transform, failing on either.
    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        let upstreamOutput: Upstream.Output
        do {
            upstreamOutput = try upstream.parse(&input)
        } catch {
            throw .left(error)
        }
        do {
            return try transform(upstreamOutput)
        } catch {
            throw .right(error)
        }
    }
}

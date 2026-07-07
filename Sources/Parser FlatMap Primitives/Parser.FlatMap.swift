//
//  Parser.FlatMap.swift
//  swift-standards
//
//  Dependent parser chaining.
//

extension Parser {
    /// A parser that chains two parsers where the second depends on the first's output.
    ///
    /// This is the monad `flatMap` (or `bind`) operation for parsers.
    ///
    /// Created via `parser.flatMap(_:)`.
    public struct FlatMap<Upstream: Parser.`Protocol`, Downstream: Parser.`Protocol`>
    where Upstream.Input == Downstream.Input {
        @usableFromInline
        let upstream: Upstream

        @usableFromInline
        let transform: (Upstream.Output) -> Downstream

        /// Creates a parser that derives the next parser from the upstream output.
        @inlinable
        public init(
            upstream: Upstream,
            transform: @escaping (Upstream.Output) -> Downstream
        ) {
            self.upstream = upstream
            self.transform = transform
        }
    }
}

extension Parser.FlatMap: Parser.`Protocol` {
    /// The input type this parser consumes.
    public typealias Input = Upstream.Input
    /// The output type this parser produces: the downstream parser's output.
    public typealias Output = Downstream.Output
    /// The error type this parser can throw, discriminating upstream from downstream failures.
    public typealias Failure = Either<Upstream.Failure, Downstream.Failure>

    /// Parses the upstream value, derives the downstream parser from it, then parses that.
    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        let upstreamOutput: Upstream.Output
        do {
            upstreamOutput = try upstream.parse(&input)
        } catch {
            throw .left(error)
        }
        let downstream = transform(upstreamOutput)
        do {
            return try downstream.parse(&input)
        } catch {
            throw .right(error)
        }
    }
}

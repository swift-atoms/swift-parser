//
//  Parser.Converted.swift
//  swift-parser-primitives
//
//  A parser-printer whose output is mapped through a Conversion.
//

public import Either_Primitives

extension Parser {
    /// A parser formed by mapping an upstream parser's output through a
    /// ``Parser/Conversion/Protocol``.
    ///
    /// Parsing runs the upstream parser, then the conversion's
    /// ``Parser/Conversion/Protocol/apply(_:)``. Printing runs the conversion's
    /// ``Parser/Conversion/Protocol/unapply(_:)``, then the upstream printer.
    /// The result is `Parser.Bidirectional` (the Coder-based form in swift-coder-primitives) exactly when the upstream is —
    /// this is the mechanism that lets a bidirectional parser-printer change its
    /// `Output` type without losing printability.
    ///
    /// Created via ``Parser/Protocol/map(_:)-conversion``.
    ///
    /// ## Naming precedent
    ///
    /// `Parser.Converted` follows the past-participle combinator naming already
    /// established by `Parser.Tracked` and `Parser.Spanned`: a parser named for
    /// the transformation it carries.
    ///
    /// ## Error composition
    ///
    /// The `Failure` discriminates the failing stage:
    /// `Either<Upstream.Failure, Downstream.Failure>` — `.left` for the upstream
    /// parser/printer, `.right` for the conversion, in both directions.
    public struct Converted<
        Upstream: Parser.`Protocol`,
        Downstream: Parser.Conversion.`Protocol`
    > where Downstream.Input == Upstream.Output {
        @usableFromInline
        internal let upstream: Upstream

        @usableFromInline
        internal let downstream: Downstream

        /// Wraps the upstream parser, mapping its output through the conversion.
        @inlinable
        public init(upstream: Upstream, downstream: Downstream) {
            self.upstream = upstream
            self.downstream = downstream
        }
    }
}

extension Parser.Converted: Parser.`Protocol` {
    /// The input type this parser consumes.
    public typealias Input = Upstream.Input
    /// The output type this parser produces: the conversion's output.
    public typealias Output = Downstream.Output
    /// The error type, discriminating parser (`.left`) from conversion (`.right`).
    public typealias Failure = Either<Upstream.Failure, Downstream.Failure>

    /// Parses with the upstream parser, then applies the conversion forward.
    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        let upstreamOutput: Upstream.Output
        do throws(Upstream.Failure) {
            upstreamOutput = try upstream.parse(&input)
        } catch {
            throw .left(error)
        }
        do throws(Downstream.Failure) {
            return try downstream.apply(upstreamOutput)
        } catch {
            throw .right(error)
        }
    }
}

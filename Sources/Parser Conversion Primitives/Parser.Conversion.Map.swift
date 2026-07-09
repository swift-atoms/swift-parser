//
//  Parser.Conversion.Map.swift
//  swift-parser-primitives
//
//  Chained composition of two conversions.
//

public import Either_Primitives

extension Parser.Conversion {
    /// A conversion that composes two conversions end to end.
    ///
    /// Applies `Upstream` then `Downstream` in the forward direction, and
    /// `Downstream` then `Upstream` in reverse. This is the functor `map` for
    /// conversions — the conversion-space analogue of `parser.map(_:)`.
    ///
    /// Created via ``Parser/Conversion/Protocol/map(_:)``.
    ///
    /// ## Error composition
    ///
    /// The `Failure` discriminates which stage failed:
    /// `Either<Upstream.Failure, Downstream.Failure>` — `.left` for the upstream
    /// conversion, `.right` for the downstream, in both directions.
    public struct Map<
        Upstream: Parser.Conversion.`Protocol`,
        Downstream: Parser.Conversion.`Protocol`
    > where Upstream.Output == Downstream.Input {
        @usableFromInline
        internal let upstream: Upstream

        @usableFromInline
        internal let downstream: Downstream

        /// Composes the upstream conversion with the downstream conversion.
        @inlinable
        public init(upstream: Upstream, downstream: Downstream) {
            self.upstream = upstream
            self.downstream = downstream
        }
    }
}

extension Parser.Conversion.Map: Parser.Conversion.`Protocol` {
    /// The type this conversion converts from.
    public typealias Input = Upstream.Input
    /// The type this conversion converts to.
    public typealias Output = Downstream.Output
    /// The error type, discriminating which stage failed.
    public typealias Failure = Either<Upstream.Failure, Downstream.Failure>

    /// Applies the upstream conversion, then the downstream conversion.
    @inlinable
    public func apply(_ input: Input) throws(Failure) -> Output {
        let middle: Upstream.Output
        do throws(Upstream.Failure) {
            middle = try upstream.apply(input)
        } catch {
            throw .left(error)
        }
        do throws(Downstream.Failure) {
            return try downstream.apply(middle)
        } catch {
            throw .right(error)
        }
    }

    /// Un-applies the downstream conversion, then the upstream conversion.
    @inlinable
    public func unapply(_ output: Output) throws(Failure) -> Input {
        let middle: Downstream.Input
        do throws(Downstream.Failure) {
            middle = try downstream.unapply(output)
        } catch {
            throw .right(error)
        }
        do throws(Upstream.Failure) {
            return try upstream.unapply(middle)
        } catch {
            throw .left(error)
        }
    }
}

extension Parser.Conversion.`Protocol` {
    /// Composes this conversion with a downstream conversion.
    ///
    /// The downstream conversion transforms this conversion's output into a new
    /// output, preserving bidirectionality.
    ///
    /// - Parameter downstream: A conversion from this conversion's `Output`.
    /// - Returns: A conversion from this conversion's `Input` to the downstream's `Output`.
    @inlinable
    public func map<Downstream: Parser.Conversion.`Protocol`>(
        _ downstream: Downstream
    ) -> Parser.Conversion.Map<Self, Downstream>
    where Output == Downstream.Input {
        .init(upstream: self, downstream: downstream)
    }
}

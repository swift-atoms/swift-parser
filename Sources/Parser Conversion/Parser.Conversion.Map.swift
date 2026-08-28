public import Either

extension Parser.Conversion {

    public struct Map<
        Upstream: Parser.Conversion.`Protocol`,
        Downstream: Parser.Conversion.`Protocol`
    > where Upstream.Output == Downstream.Input {
        @usableFromInline
        internal let upstream: Upstream

        @usableFromInline
        internal let downstream: Downstream

        @inlinable
        public init(upstream: Upstream, downstream: Downstream) {
            self.upstream = upstream
            self.downstream = downstream
        }
    }
}

extension Parser.Conversion.Map: Parser.Conversion.`Protocol` {

    public typealias Input = Upstream.Input

    public typealias Output = Downstream.Output

    public typealias Failure = Either<Upstream.Failure, Downstream.Failure>

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

    @inlinable
    public func map<Downstream: Parser.Conversion.`Protocol`>(
        _ downstream: Downstream
    ) -> Parser.Conversion.Map<Self, Downstream>
    where Output == Downstream.Input {
        .init(upstream: self, downstream: downstream)
    }
}

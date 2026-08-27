public import Either

extension Parser {

    public struct Converted<
        Upstream: Parser.`Protocol`,
        Downstream: Parser.Conversion.`Protocol`
    > where Downstream.Input == Upstream.Output {

        public let upstream: Upstream

        public let downstream: Downstream

        @inlinable
        public init(upstream: Upstream, downstream: Downstream) {
            self.upstream = upstream
            self.downstream = downstream
        }
    }
}

extension Parser.Converted: Parser.`Protocol` {

    public typealias Input = Upstream.Input

    public typealias Output = Downstream.Output

    public typealias Failure = Either<Upstream.Failure, Downstream.Failure>

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

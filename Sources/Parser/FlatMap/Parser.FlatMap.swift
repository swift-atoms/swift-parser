public import Either

extension Parser {

    public struct FlatMap<Upstream: Parser.`Protocol`, Downstream: Parser.`Protocol`>
    where Upstream.Input == Downstream.Input {
        @usableFromInline
        let upstream: Upstream

        @usableFromInline
        let transform: (Upstream.Output) -> Downstream

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
        let downstream = transform(upstreamOutput)
        do throws(Downstream.Failure) {
            return try downstream.parse(&input)
        } catch {
            throw .right(error)
        }
    }
}

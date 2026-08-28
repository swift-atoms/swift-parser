public import Either

extension Parser.Map {

    public struct Throwing<E: Swift.Error> {
        @usableFromInline
        let upstream: Upstream

        @usableFromInline
        let transform: (Upstream.Output) throws(E) -> Output

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

    public typealias Input = Upstream.Input

    public typealias Failure = Either<Upstream.Failure, E>

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        let upstreamOutput: Upstream.Output
        do throws(Upstream.Failure) {
            upstreamOutput = try upstream.parse(&input)
        } catch {
            throw .left(error)
        }
        do throws(E) {
            return try transform(upstreamOutput)
        } catch {
            throw .right(error)
        }
    }
}

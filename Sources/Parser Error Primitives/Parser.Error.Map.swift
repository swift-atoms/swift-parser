extension Parser.Error {

    public struct Map<Upstream: Parser.`Protocol`, NewFailure: Swift.Error> {
        public let upstream: Upstream

        public let transform: (Upstream.Failure) -> NewFailure

        @inlinable
        package init(
            _ upstream: Upstream,
            transform: @escaping (Upstream.Failure) -> NewFailure
        ) {
            self.upstream = upstream
            self.transform = transform
        }
    }
}

extension Parser.Error.Map: Parser.`Protocol` {

    public typealias Input = Upstream.Input

    public typealias Output = Upstream.Output

    public typealias Failure = NewFailure

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        do throws(Upstream.Failure) {
            return try upstream.parse(&input)
        } catch {
            throw transform(error)
        }
    }
}

extension Parser.Error.Transform {

    @inlinable
    public func map<NewFailure: Swift.Error>(
        _ transform: @escaping (Upstream.Failure) -> NewFailure
    ) -> Parser.Error.Map<Upstream, NewFailure> {
        Parser.Error.Map(upstream, transform: transform)
    }
}

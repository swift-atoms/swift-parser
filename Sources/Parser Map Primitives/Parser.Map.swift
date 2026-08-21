extension Parser {

    public struct Map<Upstream: Parser.`Protocol`, Output> {
        @usableFromInline
        internal let upstream: Upstream

        @usableFromInline
        internal let transform: (Upstream.Output) -> Output

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

    public typealias Input = Upstream.Input

    public typealias Failure = Upstream.Failure

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        transform(try upstream.parse(&input))
    }
}

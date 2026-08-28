extension Parser {

    @frozen
    public struct Map<
        Upstream: Parser.`Protocol` & ~Copyable,
        Output: ~Copyable & Escapable,
        Failure: Swift.Error
    >: ~Copyable {
        @usableFromInline
        internal let upstream: Upstream

        @usableFromInline
        internal let transform:
            (consuming Upstream.Output) throws(Failure) -> Output

        @usableFromInline
        internal let failure: (Upstream.Failure) -> Failure

        @inlinable
        public init(
            upstream: consuming Upstream,
            transform: @escaping
                (consuming Upstream.Output) throws(Failure) -> Output,
            failure: @escaping (Upstream.Failure) -> Failure
        ) {
            self.upstream = upstream
            self.transform = transform
            self.failure = failure
        }
    }
}

extension Parser.Map: Copyable
where Upstream: Copyable, Output: ~Copyable & Escapable
{}

extension Parser.Map: Parser.`Protocol`
where Output: ~Copyable & Escapable {

    public typealias Input = Upstream.Input

    @inlinable
    public borrowing func parse(
        _ input: inout Input
    ) throws(Failure) -> Output {
        let value: Upstream.Output
        do throws(Upstream.Failure) {
            value = try upstream.parse(&input)
        } catch {
            throw failure(error)
        }
        return try transform(value)
    }
}

extension Parser {

    public struct Filter<Upstream: Parser.`Protocol`>
    where Upstream.Output: Copyable & Escapable {
        @usableFromInline
        internal let upstream: Upstream

        @usableFromInline
        internal let predicate: (Upstream.Output) -> Bool

        @inlinable
        public init(
            upstream: Upstream,
            predicate: @escaping (Upstream.Output) -> Bool
        ) {
            self.upstream = upstream
            self.predicate = predicate
        }
    }
}

extension Parser.Filter: Parser.`Protocol`
where Upstream.Output: Copyable & Escapable {

    public typealias Input = Upstream.Input

    public typealias Output = Upstream.Output

    public typealias Failure = Either<Upstream.Failure, Parser.Filter<Upstream>.Error>

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        let output: Upstream.Output
        do throws(Upstream.Failure) {
            output = try upstream.parse(&input)
        } catch {
            throw .left(error)
        }
        guard predicate(output) else {
            throw .right(.validationFailed(value: "\(output)", reason: "filter predicate"))
        }
        return output
    }
}

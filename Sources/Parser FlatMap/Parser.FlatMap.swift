extension Parser {

    public struct FlatMap<Upstream: Parser.`Protocol`, Downstream: Parser.`Protocol`>
    where
        Upstream.Input == Downstream.Input,
        Upstream.Input: ~Copyable & ~Escapable,
        Downstream.Input: ~Copyable & ~Escapable,
        Upstream.Output: ~Copyable & ~Escapable,
        Downstream.Output: Escapable
    {
        @usableFromInline
        let upstream: Upstream

        @usableFromInline
        let transform: (consuming Upstream.Output) -> Downstream

        @inlinable
        public init(
            upstream: Upstream,
            transform: @escaping (consuming Upstream.Output) -> Downstream
        ) {
            self.upstream = upstream
            self.transform = transform
        }
    }
}

extension Parser.FlatMap: Parser.`Protocol`
where
    Upstream.Input: ~Copyable & ~Escapable,
    Downstream.Input: ~Copyable & ~Escapable,
    Upstream.Output: ~Copyable & ~Escapable,
    Downstream.Output: Escapable
{

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

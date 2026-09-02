public import Either
public import Parser

extension Parser {

    public struct FlatMap<Upstream: Parser.`Protocol`, Downstream: Parser.`Protocol`>: Parser.`Protocol`
    where
        Upstream.Input == Downstream.Input,
        Upstream.Input: ~Copyable & ~Escapable,
        Downstream.Input: ~Copyable & ~Escapable,
        Upstream.Output: ~Copyable & ~Escapable,
        Downstream.Output: ~Copyable & Escapable
    {
        public typealias Input = Upstream.Input

        public typealias Output = Downstream.Output

        public typealias Failure = Either<Upstream.Failure, Downstream.Failure>

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

        @inlinable
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
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
}
